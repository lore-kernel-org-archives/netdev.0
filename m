From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IXP42x HSS support for setting internal clock rate
Date: Mon, 07 Sep 2009 01:59:05 -0700 (PDT)
Message-ID: <20090907.015905.82274829.davem@davemloft.net>
References: <m3ab19cx0q.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752496AbZIGI6u convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2009 04:58:50 -0400
In-Reply-To: <m3ab19cx0q.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 05 Sep 2009 15:59:49 +0200

> HSS usually uses external clocks, so it's not a big deal. Internal cl=
ock
> is used for direct DTE-DTE connections and when the DCE doesn't provi=
de
> it's own clock.
>=20
> This also depends on the oscillator frequency. Intel seems to have
> calculated the clock register settings for 33.33 MHz (66.66 MHz timer
> base). Their settings seem quite suboptimal both in terms of average
> frequency (60 ppm is unacceptable for G.703 applications, their prima=
ry
> intended usage(?)) and jitter.
>=20
> Many (most?) platforms use a 33.333 MHz oscillator, a 10 ppm differen=
ce
> from Intel's base.
>=20
> Instead of creating static tables, I've created a procedure to progra=
m
> the HSS clock register. The register consists of 3 parts (A, B, C).
> The average frequency (=3D bit rate) is:
> 66.66x MHz / (A  + (B + 1) / (C + 1))
> The procedure aims at the closest average frequency, possibly at the
> cost of increased jitter. Nobody would be able to directly drive an
> unbufferred transmitter with a HSS anyway, and the frequency error is
> what it really counts.
=2E..
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

Applied, thanks Krzysztof.
