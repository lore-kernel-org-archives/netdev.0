From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] af_unix: closed SOCK_SEQPACKET socketpair must get SIGPIPE
Date: Tue, 15 Mar 2016 15:35:37 +0100
Message-ID: <CAG_fn=XOvvJ2ZxJ+HGF26qPk4o3gskMTt6682CTew_ZkLdb37Q@mail.gmail.com>
References: <1458032624-139688-1-git-send-email-glider@google.com>
	<1458048051.31401.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	rweikusat@mobileactivedefense.com,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458048051.31401.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 2:20 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Tue, 2016-03-15 at 10:03 +0100, Alexander Potapenko wrote:
>> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
>> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if th=
e
>> socket is no longer connected.
>
> I find this sentence slightly confusing ?
>
> If MSG_NOSIGNAL is set, then SIGPIPE should not be generated.
>
> s/with/without/ maybe ?
>
Agreed. I've rewritten this a couple of times and failed to proof-read
it for the last time.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicl=
e
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
