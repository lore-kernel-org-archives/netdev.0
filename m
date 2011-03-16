From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk"
	name
Date: Wed, 16 Mar 2011 08:38:44 +0000
Message-ID: <20110316083844.GA13262@n2100.arm.linux.org.uk>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com> <1300184096-13937-2-git-send-email-jamie@jamieiles.com> <AANLkTimwwUQGhncE7Att_9rAXhpT0n61HC4SW8ShSfAm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: "avictor.za@gmail.com" <avictor.za@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33021 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab1CPIjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 04:39:00 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimwwUQGhncE7Att_9rAXhpT0n61HC4SW8ShSfAm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2011 at 08:53:47AM +0200, avictor.za@gmail.com wrote:
> hi,
>=20
> On Tue, Mar 15, 2011 at 12:14 PM, Jamie Iles <jamie@jamieiles.com> wr=
ote:
> > The macb driver expects clocks with the names "pclk" and "hclk". =A0=
We
> > currently provide "macb_clk" but to fit in line with other
> > architectures (namely AVR32), provide "pclk" and a fake "hclk".
>=20
> There is no reference to a "pclk" or "hclk" in the AT91 architecture.
> So to avoid possible confusion, maybe create two "fake" clocks both
> parented to "macb_clk", and add a comment they're only for
> compatibility with the AVR32.

It doesn't matter what's in the documentation.

There's no apb_pclk mentioned in the ARM platform documentation yet we
have such a clock in the bus-level code for primecell support.  I'm sur=
e
many of the other early primecell using platforms are also the same.

On OMAP1 there's no iclk yet OMAP drivers have had iclk and iclk is a
dummy no-op clock for OMAP1 for compatibility with OMAP2.

What matters more than conforming to documentation is keeping the drive=
rs
in a clean and maintainable state without throwing lots of ifdefs into
them.
