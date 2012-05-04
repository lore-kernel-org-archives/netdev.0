From: "dilieto@lineone.net" <dilieto@lineone.net>
Subject: Re: [REGRESSION][PATCH] Fix an old sky2 WOL regression
Date: Fri, 4 May 2012 21:17:02 +0100 (BST)
Message-ID: <32467848.260261336162622524.JavaMail.defaultUser@defaultHost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, arekm@maven.pl,
	Jared <nitro@legroom.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Knut_Petersen@t-online.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Knut,

I am sorry it took a while to try it due to other=20
commitments, however I can now confirm the patch works on my ASUS P5LD2=
=20
motherboard.

Many thanks
Nicola

On 2012-03-21 12:40, Knut Petersen=20
wrote:
> Sky2 Wake on LAN is broken since February 2010 on a number of=20
systems.
> Yes. More than two years.
>
> We know about the problem and=20
the cause since October 2010
> (Bugzilla bug #19492). It=C2=B4s commit=20
87b09f1f25cd1e01d7c50bf423c7fe33027d7511.
>
> Stephen, David: You=20
signed off that commit.
>
> Andrew: You called it a regression in=20
October 2010.
>
> It has been proposed to revert the commit that caused=20
the problem.
> Nothing happened.
>
> I proposed to re-establish the old=20
code for dmi_match()ed systems.
> Without success.
>
> Now it is=20
proposed to re-establish the old code as a configuration option.
> If=20
nothing happens again I will propose a module parameter ;-)
>
>=20
Stephen, I don=C2=B4t want to be a pain in the neck, and it is not my=20
intention
> to offend you by my "attitude". But I simply cannot=20
understand why this
> know regression is not fixed. The bit we talk=20
about is documented,
> and in fact it was set for a number of kernel=20
versions unconditionally.
> Nobody complained about ruined hardware or=20
minor problems.
>
> The systems affected are old enough that no=20
manufacturer cares about
> them, but they are still quite usable for a=20
lot of jobs (kernel 3.3 compile
> time here is below 15 minutes).
>
>=20
If there is a problem in the kernel and if we do know an easy solution,

> that solution should be commited to the kernel, no matter what is=20
written
> in some random documentation, no matter if we could blame=20
some
> BIOS authors. That=C2=B4s the way Linux works - at least I thought=20
so.
>
> cu,
> Knut
