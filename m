From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/19] fix irq problem with NAPI + NETPOLL
Date: Tue, 6 Mar 2007 03:14:43 -0800
Message-ID: <20070306031443.d18d8bff.akpm@linux-foundation.org>
References: <200703061041.l26AfusT019768@shell0.pdx.osdl.net>
	<45ED4B23.9060000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anemo@mba.ocn.ne.jp, davem@davemloft.net,
	romieu@fr.zoreil.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36266 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933242AbXCFLPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:15:14 -0500
In-Reply-To: <45ED4B23.9060000@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 06 Mar 2007 06:06:11 -0500 Jeff Garzik <jeff@garzik.org> wrote:

> akpm@linux-foundation.org wrote:
> > From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> > 
> > It seems netif_receive_skb() was designed not to call from irq context, but
> > NAPI + NETPOLL break this rule.  If netif_receive_skb() was called from irq
> > context, redirect to netif_rx() instead of processing the skb in that
> > context.
> > 
> > Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: Francois Romieu <romieu@fr.zoreil.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  net/core/dev.c |   11 +++++++++--
> >  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> net/* stuff, I'll let DaveM make the call and apply it...

argh, sorry, this patch (which is mysteriously called
8139too-fix-irq-problem-with-napi-netpoll.patch) was supposed to go to
davem and you were supposed to receive
8139too-force-media-setting-fix.patch (which you were cc'ed on).

