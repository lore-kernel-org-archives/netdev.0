From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Sat, 5 Jul 2014 18:39:49 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407051833400.15455@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>         <20140702.182807.1245632778216212860.davem@davemloft.net>         <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>         <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
         <1404356734.14741.18.camel@joe-AO725>         <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>         <1404364565.14741.26.camel@joe-AO725>         <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>         <1404368746.14741.36.camel@joe-AO725>
         <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org> <1404576420.6384.41.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404576420.6384.41.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 5 Jul 2014, Joe Perches wrote:

> >  One question though, does either of you or anybody else know why we're 
> > inconsistent about this 0x prefixing of virtual addresses vs physical 
> > addresses?  Specifically %p vs e.g. %pad.
> 
> I think it's a mistake and I agree.
> 
> I submitted a patch to remove the prefix from %pad.
> 
> https://lkml.org/lkml/2014/3/21/333

 Great!  Your proposal looks good to me in principle, however you need to 
factor in SPECIAL having been set by `#' somehow as `number' will respect 
it.  I suggest using the same field width calculation that `pointer' uses 
for `default_width' (sans the type used with `sizeof' of course, that is).

  Maciej
