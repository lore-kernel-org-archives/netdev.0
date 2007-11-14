From: David Miller <davem@davemloft.net>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Tue, 13 Nov 2007 21:04:31 -0800 (PST)
Message-ID: <20071113.210431.141662500.davem@davemloft.net>
References: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
	<Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: guichaz@yahoo.fr, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbXKNFEc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 00:04:32 -0500
In-Reply-To: <Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 13 Nov 2007 23:35:39 +0200 (EET)

> [PATCH] [TCP] FRTO: Plug potential LOST-bit leak
>=20
> It might be possible that, in some extreme scenario that
> I just cannot now construct in my mind, end_seq <=3D
> frto_highmark check does not match causing the lost_out
> and LOST bits become out-of-sync due to clearing and
> recounting in the loop.
>=20
> This may fix LOST-bit leak reported by Chazarain Guillaume
> <guichaz@yahoo.fr>.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This patch looks correct to me, so I added it to net-2.6

Chazarain please let us know if it does indeed cure your
problem.

Thanks.
