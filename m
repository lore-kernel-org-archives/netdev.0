From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 10:47:17 +0000
Message-ID: <20080826104717.GB2609@ff.dom.local>
References: <20080826095126.GA2609@ff.dom.local> <200808261329.53741.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:38710 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbYHZKrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 06:47:23 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1699015ika.5
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 03:47:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808261329.53741.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 01:29:53PM +0300, Denys Fedoryshchenko wrote:
> On Tuesday 26 August 2008, Jarek Poplawski wrote:
> >
> > This function is really used in many places, and these profiles are
> > not enough at least to me, but it seems you could have a lot of
> > softirqs (and probably hrtimers) scheduling, so maybe you should try
> > if e.g. disabling hrtimers or changing kernel HZ makes any difference.
> >
> > Jarek P.
> One user is shapers, it is ok for me.

The question is if you really need so exact shaping at a cost of
higher system load.

> I am not sure, but maybe another user is softlockup debug option... and if 
> there is a lot of task switches maybe it will cause excessive load of timers 
> slow?

Maybe. Anyway, you could try if lower HZ (with longer jiffies) can help
with processing more skbs without rescheduling.

Jarek P.
