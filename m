From: David Miller <davem@davemloft.net>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Tue, 03 Jun 2008 15:03:44 -0700 (PDT)
Message-ID: <20080603.150344.145518113.davem@davemloft.net>
References: <20080603094057.GA29480@elte.hu>
	<Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, peterz@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rjw@sisk.pl, akpm@linux-foundation.org,
	johnpol@2ka.mipt.ru, mcmanus@ducksong.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759487AbYFCWEA@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 4 Jun 2008 01:01:25 +0300 (EEST)

> On Wed, 4 Jun 2008, Ilpo J=E4rvinen wrote:
>=20
> > ...I couldn't immediately find anything obviously wrong with those =
changes=20
> > but the patch below might be worth of a try (without the revert of=20
> > course). If it ever spits out that WARN_ON for you, we were playing=
 with=20
> > fire too much and it's better to return on the safe side there...
>=20
>=20
> > [PATCH] tcp DEFER_ACCEPT: see if header prediction got turned on
> >=20
> > If header prediction is turned on under some circumstances,
> > DA can deadlock though I have great trouble in figuring out
>=20
> ...Nah, keepalive timer would then eventually kill it then, so no
> deadlock seems possible through that one.

Keepalive is very long, it might still "seem" like a deadlock for
someone without much patience :-)
