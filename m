From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: Re: macb: zynq: why is SG disabled?
Date: Wed, 1 Jul 2015 19:04:00 +0200
Message-ID: <55941D80.2090904@atmel.com>
References: <559403E3.3050900@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nicolae Rosia <nicolae.rosia@certsign.ro>,
	Michal Simek <michal.simek@xilinx.com>,
	Punnaiah Choudary Kalluri
	<punnaiah.choudary.kalluri@xilinx.com>, <netdev@vger.kernel.org>,
	"Nicolas Ferre" <nicolas.ferre@atmel.com>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:12166 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbGARER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 13:04:17 -0400
In-Reply-To: <559403E3.3050900@certsign.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/07/2015 17:14, Nicolae Rosia a =E9crit :
> Hello,
>=20
> After reading the GEM part of Zynq7000 Technical Reference Manual [0]=
, I think that SG should be supported.
> Is there a reason why SG is disabled in macb for Zynq?
>=20
> Best regards,
> Nicolae Rosia

Hi Nicolae,

when the scatter-gather patch was introduced, the feature was enabled o=
nly on
tested boards to avoid regressions on other boards.
So SG is enabled on sama5d4x and sama5d2x SoCs. SG is disabled on purpo=
se on
sama5d3x.

=46or Zynq, I think the feature is still disabled just because it has n=
ever been
tested.

Best regards,

Cyrille
