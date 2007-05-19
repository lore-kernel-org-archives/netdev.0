From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] [TCP] FRTO: Prevent state inconsistency in
 corner cases
Date: Sat, 19 May 2007 13:57:11 -0700 (PDT)
Message-ID: <20070519.135711.85418128.davem@davemloft.net>
References: <Pine.LNX.4.64.0705181213360.28356@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0705181216570.28356@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33039
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759772AbXESU5J convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2007 16:57:09 -0400
In-Reply-To: <Pine.LNX.4.64.0705181216570.28356@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 18 May 2007 12:17:44 +0300 (EEST)

> State could become inconsistent in two cases:
>=20
> 1) Userspace disabled FRTO by tuning sysctl when one of the TCP
>    flows was in the middle of FRTO algorithm (and then RTO is
>    again triggered)
>=20
> 2) SACK reneging occurs during FRTO algorithm
>=20
> A simple solution is just to abort the previous FRTO when such
> obscure condition occurs...
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Also applied, thanks!
