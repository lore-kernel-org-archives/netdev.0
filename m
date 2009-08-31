From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 09:05:11 +0000
Message-ID: <20090831090511.GG5005@ff.dom.local>
References: <20090831053026.GA5005@ff.dom.local> <200908311118.43024.denys@visp.net.lb> <20090831.013738.127727614.davem@davemloft.net> <200908311151.22607.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50949 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbZHaJFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 05:05:15 -0400
Received: by bwz19 with SMTP id 19so2645220bwz.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 02:05:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908311151.22607.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 11:51:22AM +0300, Denys Fedoryschenko wrote:
> On Monday 31 August 2009 11:37:38 David Miller wrote:
> > From: Denys Fedoryschenko <denys@visp.net.lb>
> > Date: Mon, 31 Aug 2009 11:18:42 +0300
> >
> > > 2.6.31-rc8 i got dmesg flooded. First message appearing even without
> > > patch, i will make sure now what is a reason of that (i have HTB classes
> > > on ifb0, and TBF on pppX).
> > >
> > > [  155.199923] Attempt to kill tasklet from interrupt
> >
> > We know the reasons for this message, it's an HTB regression and we're
> > working on it.
> 
> Well, those TBF warning seems works fine, i even found one missing shaper that 
> was overflowing. Thanks to Jarek.
> For now no false positives. Message is appearing only when real overflow 
> happen.

I'm glad it helps. On the other hand, I doubt you'll have such configs
until 2.6.32 where this patch was intended. (It's a pity you didn't
report it a bit earlier.) So, let David decide...

Jarek P.
