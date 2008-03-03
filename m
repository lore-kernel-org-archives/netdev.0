From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [TCP]: Must count fack_count also when
 skipping
Date: Mon, 03 Mar 2008 12:11:29 -0800 (PST)
Message-ID: <20080303.121129.183509475.davem@davemloft.net>
References: <Pine.LNX.4.64.0803031025210.18640@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0803031541230.28251@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: guichaz@gmail.com, akpm@linux-foundation.org, ray-lk@madrabbit.org,
	cw@f00f.org, giangiacomo_mariotti@yahoo.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54085
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754165AbYCCULs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 15:11:48 -0500
In-Reply-To: <Pine.LNX.4.64.0803031541230.28251@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 3 Mar 2008 15:53:12 +0200 (EET)

> [PATCH net-2.6] [TCP]: Must count fack_count also when skipping
>=20
> It makes fackets_out to grow too slowly compared with the
> real write queue.
>=20
> This shouldn't cause those BUG_TRAP(packets <=3D tp->packets_out)
> to trigger but how knows how such inconsistent fackets_out
> affects here and there around TCP when everything is nowadays
> assuming accurate fackets_out. So lets see if this silences
> them all.
>=20
> Reported by Guillaume Chazarain <guichaz@gmail.com>.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
