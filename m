From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] bonding: fix rtnl locking merge error
Date: Thu, 8 Nov 2007 12:47:22 -0500
Message-ID: <20071108174722.GB3011@havoc.gtf.org>
References: <11943848091427-git-send-email-fubar@us.ibm.com> <11943848132752-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37885 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759989AbXKHRrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 12:47:23 -0500
Content-Disposition: inline
In-Reply-To: <11943848132752-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 06, 2007 at 01:33:28PM -0800, Jay Vosburgh wrote:
> 	Looks like I incorrectly merged one of the rtnl lock changes,
> so that one function, bonding_show_active_slave, held rtnl but didn't
> release it, and another, bonding_store_active_slave, never held rtnl but
> did release it.
> 
> 	Fixed so the first function doesn't mess with rtnl, and the
> second correctly acquires and releases rtnl.
> 
> 	Bug reported by Moni Shoua <monis@voltaire.com>
> 
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

applied 1-2

