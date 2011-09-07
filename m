From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Date: Wed, 07 Sep 2011 04:38:40 +0200
Message-ID: <1315363120.3400.54.camel@edumazet-laptop>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
	 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
	 <4E664766.40200@parallels.com>
	 <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org,
 xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki
 Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman"
 <ebiederm@xmission.com>
To: Greg Thelen <gthelen@google.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 06 septembre 2011 =C3=A0 15:12 -0700, Greg Thelen a =C3=A9crit :

> >>> +#define sk_sockets_allocated(sk)                               \
> >>> +({                                                             \
> >>> +       struct percpu_counter *__p;                             \
> >>> +       __p =3D (sk)->sk_prot->sockets_allocated(sk->sk_cgrp);    \
> >>> +       __p;                                                    \
> >>> +})
>=20
> Could this be simplified as (same applies to following few macros):
>=20
> static inline struct percpu_counter *sk_sockets_allocated(struct sock *=
sk)
> {
>         return sk->sk_prot->sockets_allocated(sk->sk_cgrp);
> }
>=20

Please Greg, dont copy/paste huge sequence of code if you dont have
anymore comments.

Right before sending your mail, remove all parts that we already got in
previous mails.

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
