From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl
 modules)
Date: Thu, 31 May 2007 21:38:34 -0700 (PDT)
Message-ID: <20070531.213834.80026176.davem@davemloft.net>
References: <20070529131951.1d9a5b84@freepuppy>
	<Pine.LNX.4.64.0705292335080.23565@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705301206130.14736@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49857
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757081AbXFAEiV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 00:38:21 -0400
In-Reply-To: <Pine.LNX.4.64.0705301206130.14736@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 30 May 2007 12:10:06 +0300 (EEST)

> Based on feedback from Stephen, I changed the commit msg bit
> clearer, the patch remains the same.
>=20
> [PATCH] [TCP]: Fix GSO ignorance of pkts_acked arg (cong.cntrl module=
s)
>=20
> The code used to ignore GSO completely, passing either way too
> small or zero pkts_acked when GSO skb or part of it got ACKed.
> In addition, there is no need to calculate the value in the loop
> but simple arithmetics after the loop is sufficient. There is
> no need to handle SYN case specially because congestion control
> modules are not yet initialized when FLAG_SYN_ACKED is set.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Patch applied, thanks a lot!

I'll push this one to -stable too.

Thanks again.
