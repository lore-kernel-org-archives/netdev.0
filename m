From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Fri, 28 Oct 2016 10:58:53 +0200
Message-ID: <29de7555-9a84-0b29-3e49-a96fa26390f0@pengutronix.de>
References: <20161024191126.30256-1-socketcan@hartkopp.net>
 <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com>
 <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
 <d76a80c3-cbd2-a286-82de-4c26e372de56@pengutronix.de>
 <CAM_iQpUVB3g6gq9-RX0QAzM_ojOS0q+jq9n9objyFwyTHPAgkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="mmPImgQOnaX5FFaHfoX1OIgMNKx6s8QKL"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48691 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758920AbcJ1I7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 04:59:08 -0400
In-Reply-To: <CAM_iQpUVB3g6gq9-RX0QAzM_ojOS0q+jq9n9objyFwyTHPAgkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mmPImgQOnaX5FFaHfoX1OIgMNKx6s8QKL
Content-Type: multipart/mixed; boundary="VljLi1BEOTdTUhReW5PUNBkHtEsXXivtq";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
 Andrey Konovalov <andreyknvl@google.com>, David Miller
 <davem@davemloft.net>, linux-can@vger.kernel.org,
 Linux Kernel Network Developers <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>,
 Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>,
 Dmitry Vyukov <dvyukov@google.com>, Eric Dumazet <edumazet@google.com>
Message-ID: <29de7555-9a84-0b29-3e49-a96fa26390f0@pengutronix.de>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
References: <20161024191126.30256-1-socketcan@hartkopp.net>
 <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com>
 <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
 <d76a80c3-cbd2-a286-82de-4c26e372de56@pengutronix.de>
 <CAM_iQpUVB3g6gq9-RX0QAzM_ojOS0q+jq9n9objyFwyTHPAgkw@mail.gmail.com>
In-Reply-To: <CAM_iQpUVB3g6gq9-RX0QAzM_ojOS0q+jq9n9objyFwyTHPAgkw@mail.gmail.com>

--VljLi1BEOTdTUhReW5PUNBkHtEsXXivtq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/27/2016 06:28 PM, Cong Wang wrote:
>>> Hmm, bo->bound should guarantee it, so never mind, your patch
>>> looks fine.
>>
>> Can I add your Acked-by?
>=20
> Of course.
>=20
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--VljLi1BEOTdTUhReW5PUNBkHtEsXXivtq--

--mmPImgQOnaX5FFaHfoX1OIgMNKx6s8QKL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYExNNAAoJED07qiWsqSVqM1AH/0Aa7FBTruLSeEP98xIPVfqY
ZFi57dsx3+QsIXHafpUEEH0vnSjbgkkWNhA8HDl9YFnPNpq5wj92P8rHMs34wzLm
Kybc8MgXOQnktPC5YGXwO6II9KQMe3PelALivuZYnLxqg9ZnGAf3Bv6z4oD4Rp2r
TUUXPUgXHEfnkMLI+d/S8JLbhXIJxNX34v7OtB73uSI1LjoZsP5vDeJ3qIZOI8wO
8aLwOJcLsIw1GaaE2t7sknEB9NWaFy2FGqXRRMRi6v4gb2hT2JfTMaANEwtMBkBH
fMH1t7xJ+lcF0w/Z7sNP2eAwLqlqQneSIpj4jMxm0tfVg9aX9l7uYe3pQMTwexs=
=kHli
-----END PGP SIGNATURE-----

--mmPImgQOnaX5FFaHfoX1OIgMNKx6s8QKL--
