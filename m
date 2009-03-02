From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/17] tcp: remove redundant code from
 tcp_mark_lost_retrans
Date: Mon, 02 Mar 2009 03:01:58 -0800 (PST)
Message-ID: <20090302.030158.40105696.davem@davemloft.net>
References: <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannemann@nets.rwth-aachen.de
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755085AbZCBLCQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:02:16 -0500
In-Reply-To: <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:32 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Arnd Hannemann <hannemann@nets.rwth-aachen.de> noticed and was
> puzzled by the fact that !tcp_is_fack(tp) leads to early return
> near the beginning and the later on tcp_is_fack(tp) was still
> used in an if condition. The later check was a left-over from
> RFC3517 SACK stuff (=3D=3D !tcp_is_fack(tp) behavior nowadays) as
> there wasn't clear way how to handle this particular check
> cheaply in the spirit of RFC3517 (using only SACK blocks, not
> holes + SACK blocks as with FACK). I sort of left it there as
> a reminder but since it's confusing other people just remove
> it and comment the missing-feature stuff instead.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
