From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
Date: Thu, 27 Oct 2016 10:45:09 +0200
Message-ID: <d76a80c3-cbd2-a286-82de-4c26e372de56@pengutronix.de>
References: <20161024191126.30256-1-socketcan@hartkopp.net>
 <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com>
 <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="d4r9QGFWHDekU0wWKIcRFO45U0EqAlfQO"
Cc: Andrey Konovalov <andreyknvl@google.com>,
        David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53482 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754491AbcJ0JQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 05:16:45 -0400
In-Reply-To: <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--d4r9QGFWHDekU0wWKIcRFO45U0EqAlfQO
Content-Type: multipart/mixed; boundary="rehxdfxGc3rJ8miBeoDahGw95ICeebgk3";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Cong Wang <xiyou.wangcong@gmail.com>,
 Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Andrey Konovalov <andreyknvl@google.com>,
 David Miller <davem@davemloft.net>, linux-can@vger.kernel.org,
 Linux Kernel Network Developers <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>,
 Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>,
 Dmitry Vyukov <dvyukov@google.com>, Eric Dumazet <edumazet@google.com>
Message-ID: <d76a80c3-cbd2-a286-82de-4c26e372de56@pengutronix.de>
Subject: Re: [PATCH] can: fix warning in bcm_connect/proc_register
References: <20161024191126.30256-1-socketcan@hartkopp.net>
 <CAM_iQpXj3ktALCmjwaPKJuf0SDEc6Txk-yYkRzZ79LFEsxOx3w@mail.gmail.com>
 <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>
In-Reply-To: <CAM_iQpVmhH_9vQcTw+wP1qmPLOijZZrMZrq=_e4i5fUXYDON0Q@mail.gmail.com>

--rehxdfxGc3rJ8miBeoDahGw95ICeebgk3
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/24/2016 10:17 PM, Cong Wang wrote:
> On Mon, Oct 24, 2016 at 1:10 PM, Cong Wang <xiyou.wangcong@gmail.com> w=
rote:
>> On Mon, Oct 24, 2016 at 12:11 PM, Oliver Hartkopp
>> <socketcan@hartkopp.net> wrote:
>>>         if (proc_dir) {
>>>                 /* unique socket address as filename */
>>>                 sprintf(bo->procname, "%lu", sock_i_ino(sk));
>>>                 bo->bcm_proc_read =3D proc_create_data(bo->procname, =
0644,
>>>                                                      proc_dir,
>>>                                                      &bcm_proc_fops, =
sk);
>>> +               if (!bo->bcm_proc_read) {
>>> +                       ret =3D -ENOMEM;
>>> +                       goto fail;
>>> +               }
>>
>> Well, I meant we need to call proc_create_data() once per socket,
>> so we need a check before proc_create_data() too.
>=20
> Hmm, bo->bound should guarantee it, so never mind, your patch
> looks fine.

Can I add your Acked-by?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--rehxdfxGc3rJ8miBeoDahGw95ICeebgk3--

--d4r9QGFWHDekU0wWKIcRFO45U0EqAlfQO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJYEb6VAAoJED07qiWsqSVq47QIAJ1DE+6QznhMnKnqyOP3p0lW
8o5kE6t+EvRB7zVd/aLX35qTKqIC20kfbaNe0HI9XTjp+QzEU9Hk0OkkJyBjbRpC
GPnsA1t+U2QaS/au5wBZM/nTkEcAZ6YZDtZy7SkuWOzo8+Uxu2RTGAmO4K+T9lom
RyoIcWjJM2EZh26ac8yu2s+duvqSRNoNOerSFKc2SqUTtwW6G1ej1cfC5w91NPP6
7lfPThHJvVV0qf46hBiBFD5X1TFZ8me9nm54Dp8Ds2+81wpH8dOpPTosM/Gb2XiE
9GJfszk3e4KSDNI7ZxeX1v7bow+xpCw99HWaZ/SVcNhdtj96TVFrYEU8wKE6yqg=
=F/hp
-----END PGP SIGNATURE-----

--d4r9QGFWHDekU0wWKIcRFO45U0EqAlfQO--
