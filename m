From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [REGRESSION][PATCH] Fix an old sky2 WOL regression
Date: Wed, 21 Mar 2012 08:08:01 -0700
Message-ID: <20120321080801.55e4731b@nehalam.linuxnetplumber.net>
References: <4F69BE2E.7070903@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, arekm@maven.pl,
	Jared <nitro@legroom.net>, dilieto@lineone.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Knut Petersen <Knut_Petersen@t-online.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F69BE2E.7070903@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Mar 2012 12:40:30 +0100
Knut Petersen <Knut_Petersen@t-online.de> wrote:

> Sky2 Wake on LAN is broken since February 2010 on a number of systems=
=2E
> Yes. More than two years.
>=20
> We know about the problem and the cause since October 2010
> (Bugzilla bug #19492). It=B4s commit 87b09f1f25cd1e01d7c50bf423c7fe33=
027d7511.
>=20
> Stephen, David: You signed off that commit.
>=20
> Andrew: You called it a regression in October 2010.
>=20
> It has been proposed to revert the commit that caused the problem.
> Nothing happened.
>=20
> I proposed to re-establish the old code for dmi_match()ed systems.
> Without success.
>=20
> Now it is proposed to re-establish the old code as a configuration op=
tion.
> If nothing happens again I will propose a module parameter ;-)
>=20
> Stephen, I don=B4t want to be a pain in the neck, and it is not my in=
tention
> to offend you by my "attitude". But I simply cannot understand why th=
is
> know regression is not fixed. The bit we talk about is documented,
> and in fact it was set for a number of kernel versions unconditionall=
y.
> Nobody complained about ruined hardware or minor problems.
>=20
> The systems affected are old enough that no manufacturer cares about
> them, but they are still quite usable for a lot of jobs (kernel 3.3 c=
ompile
> time here is below 15 minutes).
>=20
> If there is a problem in the kernel and if we do know an easy solutio=
n,
> that solution should be commited to the kernel, no matter what is wri=
tten
> in some random documentation, no matter if we could blame some
> BIOS authors. That=B4s the way Linux works - at least I thought so.
>=20
> cu,
> Knut

Config options don't work for distro's.
