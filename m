From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_summed setting for TCP pure-ACK packets
Date: Mon, 08 Nov 2010 17:56:06 +0100
Message-ID: <1289235366.15376.3.camel@edumazet-laptop>
References: <1289234113.2222.20.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54821 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab0KHQ4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 11:56:11 -0500
Received: by eye27 with SMTP id 27so2893055eye.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 08:56:09 -0800 (PST)
In-Reply-To: <1289234113.2222.20.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 16:35 +0000, Ben Hutchings a =C3=A9cri=
t :
> As we discussed at LPC:
>=20
> Current controllers handled by the sfc driver have a per-queue (rathe=
r
> than per-packet) option for checksum generation.  Currently pure-ACK
> packets sent by TCP have ip_summed =3D=3D CHECKSUM_NONE and we must s=
end
> them on hardware queues with checksum generation disabled.  To suppor=
t
> this, we allocate 2 hardware queues per core TX queue.
>=20
> To reduce the risk of reordering (and possibly the number of hardware=
 TX
> queues required), it would be helpful for TCP to set ip_summed =3D=3D
> CHECKSUM_PARTIAL on pure-ACK packets when the output device is known =
to
> support checksum generation.
>=20
> Ben.
>=20

Hmm

Do you mean commit 2e8e18ef52e7dd1af0a3bd1 is not enough ?



