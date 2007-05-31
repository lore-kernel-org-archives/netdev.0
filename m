From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] [TCP]: Tighten tcp_sock's belt, drop left_out
Date: Thu, 31 May 2007 01:42:41 -0700 (PDT)
Message-ID: <20070531.014241.28790645.davem@davemloft.net>
References: <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754343AbXEaIm1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 04:42:27 -0400
In-Reply-To: <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 May 2007 11:35:56 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> It is easily calculable when needed and user are not that many
> after all.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This looks good, but are you absolutely sure we never used
a stale value of tp->left_out on purpose?

I tried to audit this but there are so many cases :-)

What I mean here is, was there a case where we updated
sacked_out or lost_out, but then used left_out before
it was updated, and we were doing this on purpose?
