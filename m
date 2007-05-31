From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] [TCP] FRTO: remove unnecessary fackets/sacked_out
 recounting
Date: Thu, 31 May 2007 01:40:19 -0700 (PDT)
Message-ID: <20070531.014019.45183560.davem@davemloft.net>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756742AbXEaIkG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 04:40:06 -0400
In-Reply-To: <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 May 2007 11:35:55 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> F-RTO does not touch SACKED_ACKED bits at all, so there is no
> need to recount them in tcp_enter_frto_loss. After removal of
> the else branch, nested ifs can be combined.
>=20
> This must also reset sacked_out when SACK is not in use as TCP
> could have received some duplicate ACKs prior RTO. To achieve
> that in a sane manner, tcp_reset_reno_sack was re-placed by the
> previous patch.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Looks good, applied.
