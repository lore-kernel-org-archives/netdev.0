From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 12/19] fix irq problem with NAPI + NETPOLL
Date: Tue, 06 Mar 2007 06:06:11 -0500
Message-ID: <45ED4B23.9060000@garzik.org>
References: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anemo@mba.ocn.ne.jp, davem@davemloft.net,
	romieu@fr.zoreil.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53109 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964952AbXCFLGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:06:16 -0500
In-Reply-To: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> 
> It seems netif_receive_skb() was designed not to call from irq context, but
> NAPI + NETPOLL break this rule.  If netif_receive_skb() was called from irq
> context, redirect to netif_rx() instead of processing the skb in that
> context.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  net/core/dev.c |   11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)

net/* stuff, I'll let DaveM make the call and apply it...


