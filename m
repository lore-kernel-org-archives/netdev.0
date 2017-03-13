From: Florian Westphal <fw@strlen.de>
Subject: Re: ip_rcv_finish() NULL pointer kernel panic
Date: Mon, 13 Mar 2017 18:39:42 +0100
Message-ID: <20170313173942.GB26782@breakpoint.cc>
References: <alpine.LNX.2.02.1701260927040.24491@maul.oc9.org>
 <1485446279.5145.141.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170126162433.GB1778@breakpoint.cc>
 <20170126.130428.2050566986836855986.davem@davemloft.net>
 <CAOZ2QJPUNm2ymTdcyW6HO9B2yhHv1MfeycywOajDSty0A6ZHFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
        eric.dumazet@gmail.com, lkml@rkeene.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Dan Streetman <dan.streetman@canonical.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOZ2QJPUNm2ymTdcyW6HO9B2yhHv1MfeycywOajDSty0A6ZHFQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Streetman <dan.streetman@canonical.com> wrote:
> > But I have to say that this netfilter bridging fake dst has caused
> > several dozen bugs over the years, it is fundamentally a serious
> > problem in and of itself.  It provides DST facilities by hand, in a
> > static object, without using any of the usual methods for creating and
> > facilitating dst objects.
> >
> > Therefore every time someone makes an adjustment to common dst code,
> > this turd (and yes, it _is_ a turd) breaks.  Every single time.
> >
> > So in the long term, instead of polishing this turd, let's get rid of
> > it.
> 
> I'm getting reports of this bug as well; is anyone working on removing
> the bridge fake dst?

I don't see how we can ever remove it (unless we remove the
call-iptables feature of course).
