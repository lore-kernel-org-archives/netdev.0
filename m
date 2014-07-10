From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: randconfig build error with next-20140710, in net/ipv4/ipconfig.c
Date: Thu, 10 Jul 2014 10:15:56 -0700
Message-ID: <CAGVrzcYc+B-tsvGBspD3mujYf_mMsyRx2VoYJj3hEvwkZffX1Q@mail.gmail.com>
References: <CA+r1ZhhJxs_EL3UbtL8qAK4_JAqo3sJ3fF3KJ_3=NcRhnJiYjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+r1ZhhJxs_EL3UbtL8qAK4_JAqo3sJ3fF3KJ_3=NcRhnJiYjg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-10 10:07 GMT-07:00 Jim Davis <jim.epost@gmail.com>:
> Building with the attached random configuration file,
>
> net/ipv4/ipconfig.c: In function =E2=80=98ic_dynamic=E2=80=99:
> net/ipv4/ipconfig.c:1221:3: error: =E2=80=98ic_dev_xid=E2=80=99 undec=
lared (first use
> in this function)
>    ic_dev_xid =3D d->xid;
>    ^
> net/ipv4/ipconfig.c:1221:3: note: each undeclared identifier is
> reported only once for each function it appears in
> make[2]: *** [net/ipv4/ipconfig.o] Error 1

Looks like David just fixed it with: http://patchwork.ozlabs.org/patch/=
368463/
--=20
=46lorian
