From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH tcp-2.6 2/3] [TCP]: Remove num_acked>0 checks from
 cong.ctrl mods pkts_acked
Date: Mon, 02 Jul 2007 22:09:30 -0700 (PDT)
Message-ID: <20070702.220930.16516282.davem@davemloft.net>
References: <11819058302343-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11819058303890-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11819058313153-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751360AbXGCFJK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 01:09:10 -0400
In-Reply-To: <11819058313153-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 15 Jun 2007 14:10:29 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> There is no need for such check in pkts_acked because the
> callback is not invoked unless at least one segment got fully
> ACKed (i.e., the snd_una moved past skb's end_seq) by the
> cumulative ACK's snd_una advancement.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to tcp-2.6
