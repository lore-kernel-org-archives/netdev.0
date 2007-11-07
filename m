From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [PATCH 1/2] bonding: fix rtnl locking merge error
Date: Wed, 07 Nov 2007 16:45:23 +0200
Message-ID: <4731CF83.20107@gmail.com>
References: <11943848091427-git-send-email-fubar@us.ibm.com> <11943848132752-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:19361 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753091AbXKGOpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 09:45:34 -0500
In-Reply-To: <11943848132752-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Looks like I incorrectly merged one of the rtnl lock changes,
> so that one function, bonding_show_active_slave, held rtnl but didn't
> release it, and another, bonding_store_active_slave, never held rtnl but
> did release it.
> 
> 	Fixed so the first function doesn't mess with rtnl, and the
> second correctly acquires and releases rtnl.
> 
> 	Bug reported by Moni Shoua <monis@voltaire.com>

I ran some shallow tests and it seems that the patch fixes  the problem.

thanks

