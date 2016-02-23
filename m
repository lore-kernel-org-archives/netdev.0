From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH can-next 1/2] CAN: rcar: add gen[12] fallback
 compatibility strings
Date: Tue, 23 Feb 2016 09:08:22 +0900
Message-ID: <20160223000822.GF1853@verge.net.au>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
 <1456107350-12100-2-git-send-email-horms+renesas@verge.net.au>
 <20160222033720.GA27711@rob-hp-laptop>
 <56CAD795.1090509@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh@kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55244 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831AbcBWAI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 19:08:29 -0500
Content-Disposition: inline
In-Reply-To: <56CAD795.1090509@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 10:40:37AM +0100, Marc Kleine-Budde wrote:
> On 02/22/2016 04:37 AM, Rob Herring wrote:
> > On Mon, Feb 22, 2016 at 11:15:49AM +0900, Simon Horman wrote:
> >> Add fallback compatibility string for R-Car Gen 1 and Gen2 families.
> >> This is in keeping with the fallback scheme being adopted wherever
> >> appropriate for drivers for Renesas SoCs.
> >>
> >> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> >> ---
> >>  Documentation/devicetree/bindings/net/can/rcar_can.txt | 4 +++-
> >>  drivers/net/can/rcar_can.c                             | 2 ++
> >>  2 files changed, 5 insertions(+), 1 deletion(-)
> > 
> > Acked-by: Rob Herring <robh@kernel.org>
> 
> I'm not following the latest DT discussions, is there a (new) decision
> to add such "generic" compatibles? AFAIK you add the oldest device
> that's compatible with your driver to your SoC dtsi at rightmost
> compatible. You can add one that identifies your SoC's IP core in front
> of it. So there's no need to modify the driver until an IP core needs
> different handling.
> 
> In your case you'd identify the oldest SoC that implements the Gen1 IP
> core and use this instead of "renesas,can-gen1. Same for Gen2 IP core.

In the case of Renesas R-Car hardware we know that there are generations of
SoCs, e.g. Gen 1 and Gen 2, but beyond that its not clear what the
relationship between IP blocks might be. For example, I believe that
r8a7779 is older than r8a7778 but that doesn't imply that the
latter is a descendant of the former or vice versa.
