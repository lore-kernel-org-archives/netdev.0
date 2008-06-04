From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 try#2] L2TP: Fix possible oops if transmitting or
 receiving when tunnel goes down
Date: Wed, 04 Jun 2008 15:55:03 -0700 (PDT)
Message-ID: <20080604.155503.193683091.davem@davemloft.net>
References: <200806042252.m54MqGPH004480@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756781AbYFDWzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:55:06 -0400
In-Reply-To: <200806042252.m54MqGPH004480@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Wed, 4 Jun 2008 23:52:16 +0100

> [L2TP] Fix possible oops if transmitting or receiving when tunnel goes down
> 
> Some problems have been experienced in the field which cause an oops
> in the pppol2tp driver if L2TP tunnels fail while passing data.
> 
> The pppol2tp driver uses private data that is referenced via the
> sk->sk_user_data of its UDP and PPPoL2TP sockets. This patch makes
> sure that the driver uses sock_hold() when it holds a reference to the
> sk pointer. This affects its sendmsg(), recvmsg(), getname(),
> [gs]etsockopt() and ioctl() handlers.
> 
> Tested by ISP where problem was seen. System has been up 10 days with
> no oops since running this patch. Without the patch, an oops would
> occur every 1-2 days.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com> 

Applied, thanks James.
