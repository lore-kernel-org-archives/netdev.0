From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [IPVS]: Kill some bloat
Date: Sat, 05 Jan 2008 23:12:58 -0800 (PST)
Message-ID: <20080105.231258.151771712.davem@davemloft.net>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, acme@redhat.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45812
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751462AbYAFHM7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 02:12:59 -0500
In-Reply-To: <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat,  5 Jan 2008 15:39:06 +0200

> net/ipv4/ipvs/ip_vs_xmit.c:
>   ip_vs_icmp_xmit   | -638
>   ip_vs_tunnel_xmit | -674
>   ip_vs_nat_xmit    | -716
>   ip_vs_dr_xmit     | -682
>  4 functions changed, 2710 bytes removed, diff: -2710
>=20
> net/ipv4/ipvs/ip_vs_xmit.c:
>   __ip_vs_get_out_rt | +595
>  1 function changed, 595 bytes added, diff: +595
>=20
> net/ipv4/ipvs/ip_vs_xmit.o:
>  5 functions changed, 595 bytes added, 2710 bytes removed, diff: -211=
5
>=20
> Without some CONFIG.*DEBUGs:
>=20
> net/ipv4/ipvs/ip_vs_xmit.o:
>  5 functions changed, 383 bytes added, 1513 bytes removed, diff: -113=
0
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks.
