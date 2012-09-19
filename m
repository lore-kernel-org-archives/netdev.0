From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] batman-adv: make batadv_test_bit() return 0 or 1
 only
Date: Wed, 19 Sep 2012 15:50:49 -0400 (EDT)
Message-ID: <20120919.155049.1144637355081576911.davem@davemloft.net>
References: <1347619254-22862-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	linus.luessing@web.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab2ISTuv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:50:51 -0400
In-Reply-To: <1347619254-22862-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <ordex@autistici.org>
Date: Fri, 14 Sep 2012 12:40:54 +0200

> From: Linus L=FCssing <linus.luessing@web.de>
>=20
> On some architectures test_bit() can return other values than 0 or 1:
>=20
> With a generic x86 OpenWrt image in a kvm setup (batadv_)test_bit()
> frequently returns -1 for me, leading to batadv_iv_ogm_update_seqnos(=
)
> wrongly signaling a protected seqno window.
>=20
> This patch tries to fix this issue by making batadv_test_bit() return=
 0
> or 1 only.
>=20
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>
> Acked-by: Sven Eckelmann <sven@narfation.org>
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>

Indeed, for variable bit testing x86 uses the 'sbb' instruction
to form the result.  So we either get 0 or -1 from test_bit().

Patch applied, thanks a lot.
