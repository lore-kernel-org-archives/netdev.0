From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Neterion and UFO handling [was: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO]
Date: Wed, 23 Oct 2013 20:15:56 +0200
Message-ID: <20131023181556.GE2403@order.stressinduktion.org>
References: <20131002085842.GA1528@minipsycho.brq.redhat.com> <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com> <20131002121207.GO10771@order.stressinduktion.org> <20131002130329.GP10771@order.stressinduktion.org> <1380726867.19002.104.camel@edumazet-glaptop.roam.corp.google.com> <20131002162730.GA3991@order.stressinduktion.org> <CAPoiz9wxxvHfmmMOCvPstzT51BafGfU1u5umxBQ8kqqCE=OzbQ@mail.gmail.com> <20131008145331.GA4767@order.stressinduktion.org> <20131017044551.GE18135@order.stressinduktion.org> <CAPoiz9xnvmQ18D0iGdFVKL8bD-1nC=8zQVD9o1oxfT4Qc942xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53355 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab3JWSP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 14:15:59 -0400
Content-Disposition: inline
In-Reply-To: <CAPoiz9xnvmQ18D0iGdFVKL8bD-1nC=8zQVD9o1oxfT4Qc942xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 09:35:43AM -0700, Jon Mason wrote:
> On Wed, Oct 16, 2013 at 9:45 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi Jon and Jiri!
> >
> > Just wanted to remind you if you could have a look at this?
> >
> > If you don't have time to test this may I know your assessment of the
> > situation? I could send a compile-time tested patch to disable UFO or if you
> > say so we could leave this as is.
> 
> So, bad news.  My Xframe 2 adapter (the only variety that does UFO
> offload) won't fit in a standard PCI(32) slot.  Since my PCI-X system
> at home is faulty (I'm trying to fix it , but it won't be in the time
> frame you want), there is no way for me to test it on the hardware.
> Terribly sorry.
> 
> I am fine with this patch going out, since UFO is off by default.
> I'll handle any issues once they are discovered.  Alternatively, we
> could just kill UFO and make everyone's lives easier.

Oh, I missed that UFO is off by default.

If it turns out that UFO is causing broken frames it should be either
killed or (if you have the time for that) fixed. Because there shouldn't
be regressions in stable kernels I am fine with this resolution. Maybe
you can have a look at this problem once your hardware is fixed.

Thank you,

  Hannes
