From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] [TCP]: Correct fastpath entrypoint below high_seq
Date: Thu, 31 May 2007 01:44:46 -0700 (PDT)
Message-ID: <20070531.014446.97557267.davem@davemloft.net>
References: <1180168562576-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685621520-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752843AbXEaIoc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 04:44:32 -0400
In-Reply-To: <11801685621830-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 May 2007 11:36:00 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> In addition, implemented find_below using minus one. Some
> reorganization was necessary to make code efficient again.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

I wonder if this adds some case where timedout_continue can
be left as NULL and accessed?

But applied, thanks!
