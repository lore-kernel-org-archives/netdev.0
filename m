From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: memory leak in udp_table_init
Date: Mon, 27 Feb 2012 06:40:23 +0100
Message-ID: <1330321223.3330.1.camel@edumazet-laptop>
References: <4F48318E.8070902@am.sony.com>
	 <CAP=VYLp7+Apubm=PHRLSw50V9zBKmV-xFRvcO4-qAogJVp7jcw@mail.gmail.com>
	 <1330147182.2462.25.camel@edumazet-laptop>
	 <20120226.142038.556939530554716833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paul.gortmaker@windriver.com, tim.bird@am.sony.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120226.142038.556939530554716833.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 26 f=C3=A9vrier 2012 =C3=A0 14:20 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 25 Feb 2012 06:19:42 +0100
>=20
> > [PATCH] mm: add a low limit to alloc_large_system_hash
>=20
> I think you should just use zero as the default minimum for all
> call sites except this UDP case we are trying to fix.
>=20
> For example I see you used 16 for kernel/pid.c
>=20
> Let's not try to do unrelated changes like that now, we can do such
> tweaks later.

It was to match the comment we have few lines above :

/*
 * The pid hash table is scaled according to the amount of memory in th=
e
 * machine.  From a minimum of 16 slots up to 4096 slots at one gigabyt=
e or
 * more.
 */
