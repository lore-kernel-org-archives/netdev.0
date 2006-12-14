From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4][SCTP]: Handle address add/delete events in a more
 efficient way.
Date: Wed, 13 Dec 2006 16:33:14 -0800 (PST)
Message-ID: <20061213.163314.35468200.davem@davemloft.net>
References: <1166042684.4670.10.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbWLNAdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:33:15 -0500
To: sri@us.ibm.com
In-Reply-To: <1166042684.4670.10.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 13 Dec 2006 12:44:44 -0800

> [SCTP]: Handle address add/delete events in a more efficient way.
> 
> Currently in SCTP, we maintain a local address list by rebuilding the whole
> list from the device list whenever we get a address add/delete event.
> 
> This patch fixes it by only adding/deleting the address for which we
> receive the event.
> 
> Also removed the sctp_local_addr_lock() which is no longer needed as we
> now use list_for_each_safe() to traverse this list. This fixes the bugs
> in sctp_copy_laddrs_xxx() routines where we do copy_to_user() while
> holding this lock.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks Sridhar.
