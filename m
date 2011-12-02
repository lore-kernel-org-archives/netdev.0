From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 1/1] net/macb: add DT support
Date: Fri, 2 Dec 2011 15:38:32 +0000
Message-ID: <20111202153832.GA4998@totoro>
References: <1321626565-11261-1-git-send-email-plagnioj@jcrosoft.com>
 <20111118155824.GA9981@totoro>
 <20111120164740.GC21480@game.jcrosoft.org>
 <20111120171123.GA7845@gallagher>
 <4ED8EF1C.80503@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	devicetree-discuss@ozlabs.org, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49261 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756858Ab1LBPif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 10:38:35 -0500
Received: by bkas6 with SMTP id s6so3988895bka.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 07:38:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4ED8EF1C.80503@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2011 at 04:30:36PM +0100, Nicolas Ferre wrote:
> On 11/20/2011 06:11 PM, Jamie Iles :
> >On Sun, Nov 20, 2011 at 05:47:40PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> >>On 15:58 Fri 18 Nov     , Jamie Iles wrote:
[...]
> >>>>+		compatible = "atmel,macb";
> >>>
> >>>This should be "cdns,macb" as it isn't Atmel specific.  I believe cdns
> >>>is the correct stock ticker symbol for Cadence.
> >>here I put "atmel,macb" on purpose to specify the difference of the IP between
> >>the soc, in fact it should have been atmel-at91,macb
> >
> >Well if we really can't detect the difference from the revision register
> >then we should have "cdns,macb" *and* "atmel,at91-macb" at least then
> >where platforms could claim compatibility as:
> >
> >	compatible = "atmel,at91-macb", "cdns,macb";
> 
> re-thinking about this I propose that we go for the following
> compatible string for macb:
> 
> - compatible: Should be "cdns,<chip>-macb"
> 
> And as the first SoC that have embedded an emacb that is compatible
> with current 10/100 AT91 usage is AVR32 at32ap7000... We may end up
> with "cdns,at32ap7000-macb" compatible string. The first ones with
> different synthesis parameters where at91sam9260/3 so I may also
> add:
> "cdns,at91sam9260-macb".
> Then you will have to add the first SoC that uses the gigabit
> version of the macb...
> What do you think about that?

Sure, that works for me, though I guess this is a much more general 
thing than this one binding, but that does make sense to me.  I think 
that keeping a general "cdns,macb" _too_ still makes sense though as 
lots of it may well be detectable and it will probably be difficult for 
one SoC vendor to know whether their IP instantiation really is the same 
as another vendors...  Either way I don't have a strong opinion on that.

> BTW, "cdns" seems not included in the vendor-prefixes.txt file yet...

No, that one is missing.  If you want to add it then feel free, if not 
I'll add it to my list of patches to do!

Jamie
