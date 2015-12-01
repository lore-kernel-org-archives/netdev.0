From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: add R8A7791 support
Date: Tue, 1 Dec 2015 15:24:37 +0900
Message-ID: <20151201062437.GE16260@verge.net.au>
References: <6051623.qN4lqSyZKg@wasted.cogentembedded.com>
 <CAMuHMdWE_G2WqsGZEaa4Ck3zziTLGVPfaVdU2gbnLA5zWpmR1w@mail.gmail.com>
 <565B6AAD.8080205@cogentembedded.com>
 <20151130004207.GD3501@verge.net.au>
 <565C9EA6.309@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42264 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbbLAGYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 01:24:40 -0500
Content-Disposition: inline
In-Reply-To: <565C9EA6.309@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 10:08:22PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/30/2015 03:42 AM, Simon Horman wrote:
> 
> >>>>Add support  for yet another ARM member of the R-Car family, R-Car M2, also
> >>
> >>>R-Car M2-W?
> >>
> >>    Right, forgot about the postfixes.
> >>
> >>>>known as R8A7791.
> >>>
> >>>There's also R-Car M2-N, aka R8A7793, but you probably know that ;-)
> >>
> >>    Will fix.
> >
> >I would prefer if we added generic gen2 and gen3 compat strings to the driver
> >and only documented new soc-specific compat strings.
> 
>    That's a new policy it seems. Previously you preferred the SoC-specific
> strings to be used, didn;t you?

Yes, that is correct on all counts.

To clarify new policy for Renesas IP is:
	soc-specific compat + generic compat as fallback

> >Actually by chance I was planning to up patches to do that and add compat
> >strings for the missing Gen2 boards. But I won't complain if you beat me to
> >it.
> 
>    No, I'm pretty busy as is. :-)

Ok, I'll handle this.
