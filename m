From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] tcpv6: combine tcp_v6_send_(reset|ack)
Date: Thu, 09 Oct 2008 14:42:50 -0700 (PDT)
Message-ID: <20081009.144250.238182808.davem@davemloft.net>
References: <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1223544937-12595-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1223544937-12595-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753802AbYJIVnO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 17:43:14 -0400
In-Reply-To: <1223544937-12595-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu,  9 Oct 2008 12:35:37 +0300

> $ codiff tcp_ipv6.o.old tcp_ipv6.o.new
> net/ipv6/tcp_ipv6.c:
>   tcp_v6_md5_hash_hdr | -144
>   tcp_v6_send_ack     | -585
>   tcp_v6_send_reset   | -540
>  3 functions changed, 1269 bytes removed, diff: -1269
>=20
> net/ipv6/tcp_ipv6.c:
>   tcp_v6_send_response | +791
>  1 function changed, 791 bytes added, diff: +791
>=20
> tcp_ipv6.o.new:
>  4 functions changed, 791 bytes added, 1269 bytes removed, diff: -478
>=20
> I choose to leave the reset related netns comment in place (not
> the one that is killed) as I cannot understand its English so
> it's a bit hard for me to evaluate its usefulness :-).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks!
