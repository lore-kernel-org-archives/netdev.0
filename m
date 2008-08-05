From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/2 respin] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Tue, 5 Aug 2008 06:47:41 +0000
Message-ID: <20080805064740.GB4407@ff.dom.local>
References: <20080804085734.GB12927@ff.dom.local> <20080804.231449.199557608.davem@davemloft.net> <20080805063423.GA4407@ff.dom.local> <20080804.233122.132106854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:28943 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbYHEGmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 02:42:15 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1503042wxd.4
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 23:42:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080804.233122.132106854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 11:31:22PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 5 Aug 2008 06:34:23 +0000
> 
> > NAK! You're not allowed to remove such a great comment!
> > 
> > BTW, I hope you've checked this enough, becouse I've some doubts
> > here: this NET_XMIT_BYPASS looks wrong here but maybe it was meant
> > to be some NET_RX_ code, like NET_RX_CN_HIGH?
> 
> I think it was trying to handle the cases where the
> input packet called dev_queue_xmit() and that return
> value funnelled back into dst_input().
> 
> But that couldn't happen, and even if it could dev_queue_xmit()
> always "fixed up" NET_XMIT_BYPASS so that callers never saw it.
> 
> Really, this code was totally useless as far as I can tell.

This looks reasonable, the only doubt is if it could get anywhere
this NET_RX_CN_HIGH (against original intention), because then
there would be some change. Anyway, the comment could stay...

Jarek P.
