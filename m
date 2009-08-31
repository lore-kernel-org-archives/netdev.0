From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 08:58:49 +0000
Message-ID: <20090831085848.GF5005@ff.dom.local>
References: <20090831053026.GA5005@ff.dom.local> <20090830.223239.185830289.davem@davemloft.net> <200908311118.43024.denys@visp.net.lb> <20090831.013738.127727614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:38429 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbZHaI6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:58:52 -0400
Received: by fxm17 with SMTP id 17so2624607fxm.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 01:58:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090831.013738.127727614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 01:37:38AM -0700, David Miller wrote:
> From: Denys Fedoryschenko <denys@visp.net.lb>
> Date: Mon, 31 Aug 2009 11:18:42 +0300
> 
> > 2.6.31-rc8 i got dmesg flooded. First message appearing even without patch, i 
> > will make sure now what is a reason of that (i have HTB classes on ifb0, and 
> > TBF on pppX).
> > 
> > [  155.199923] Attempt to kill tasklet from interrupt
> 
> We know the reasons for this message, it's an HTB regression and we're
> working on it.

There is a few more than HTB. Btw, IMHO, we don't risk much (if at
all) if we revert this qdisc_watchdog change. There is still CBQ
problem, where we could probably reconsider Thomas Gleixner's first
attempt with additional locking and irq disabling as a temporary
solution?

Jarek P.
