From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] bonding: fix error unwind in bonding_store_bonds
Date: Fri, 02 May 2008 17:51:43 -0700 (PDT)
Message-ID: <20080502.175143.179407624.davem@davemloft.net>
References: <12097757801056-git-send-email-fubar@us.ibm.com>
	<12097757822222-git-send-email-fubar@us.ibm.com>
	<12097757832778-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34535
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765435AbYECAvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:51:43 -0400
In-Reply-To: <12097757832778-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri,  2 May 2008 17:49:38 -0700

> 	Fixed an error unwind in bonding_store_bonds that didn't release
> the locks it held, and consolidated unwinds into a common block at the
> end of the function.  Bug reported by Pavel Emelyanov <xemul@openvz.org>,
> who provided a different fix.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>
