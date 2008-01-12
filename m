From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Sat, 12 Jan 2008 03:25:18 -0800 (PST)
Message-ID: <20080112.032518.110245532.davem@davemloft.net>
References: <12001304703789-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001304701053-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001304701901-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753155AbYALLZS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 06:25:18 -0500
In-Reply-To: <12001304701901-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 12 Jan 2008 11:34:29 +0200

> net/core/pktgen.c:
>   pktgen_stop_device   |  -50
>   pktgen_run           | -105
>   pktgen_if_show       |  -37
>   pktgen_thread_worker | -702
>  4 functions changed, 894 bytes removed, diff: -894
>=20
> net/core/pktgen.c:
>   getCurUs |  +36
>  1 function changed, 36 bytes added, diff: +36
>=20
> net/core/pktgen.o:
>  5 functions changed, 36 bytes added, 894 bytes removed, diff: -858
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I think this is the right thing to do, applied.
