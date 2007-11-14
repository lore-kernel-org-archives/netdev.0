From: David Miller <davem@davemloft.net>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Wed, 14 Nov 2007 15:55:51 -0800 (PST)
Message-ID: <20071114.155551.93961946.davem@davemloft.net>
References: <Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
	<20071113.210431.141662500.davem@davemloft.net>
	<Pine.LNX.4.64.0711141245050.23382@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: guichaz@yahoo.fr, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753631AbXKNXzv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 18:55:51 -0500
In-Reply-To: <Pine.LNX.4.64.0711141245050.23382@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 14 Nov 2007 15:32:58 +0200 (EET)

> [PATCH] [TCP] FRTO: Clear frto_highmark only after process_frto that =
uses it
>=20
> I broke this in commit 3de96471bd7fb76406e975ef6387abe3a0698149.
> tcp_process_frto should always see a valid frto_highmark. An
> invalid frto_highmark (zero) is very likely what ultimately
> caused a seqno compare in tcp_frto_enter_loss to do the wrong
> leading to the LOST-bit leak.
>=20
> Having LOST-bits integry ensured like done after commit
> 23aeeec365dcf8bc87fae44c533e50d0bb4f23cc won't hurt. It may
> still be useful in some other, possibly legimate, scenario.
>=20
> Reported by Chazarain Guillaume <guichaz@yahoo.fr>.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.

Thanks for making such an incredibly thorough investigation
into this bug!
