From: Chase Venters <chase.venters@clientec.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 18:59:21 -0500
Message-ID: <200606131859.43695.chase.venters@clientec.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <448F3C83.9080606@google.com> <20060613164714.B7232@openss7.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932368AbWFMX7s@vger.kernel.org>
To: bidulock@openss7.org
In-Reply-To: <20060613164714.B7232@openss7.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 June 2006 17:46, Brian F. G. Bidulock wrote:
> Daniel,
>
> On Tue, 13 Jun 2006, Daniel Phillips wrote:
> > You probably meant "non-GPL-compatible non-proprietary".  If so, th=
en by
> > definition there are none.
>
> Well, being GPL compatible is not a requirement for an open source li=
cense.
>
> IANAL, but last I checked, pure-BSD is not compatible with GPL (it ac=
tually
> has to be dual-licensed BSD/GPL).

It depends on what you mean by "pure-BSD". If you're talking about the=20
4-clause license with the advertising clause, then you are correct. Oth=
erwise=20
(IANAL) but my understanding is that BSD code can even be relicensed GP=
L by a=20
third party contribution (though it is perhaps kind to ask for relicens=
ing=20
permission anyway).

=46rom your other message:

> To some it is a serious failing of Linux (particularly those involved=
 in
> porting kernel modules from branded UNIX or embedded RTOS). =A0To tho=
se
> whatever stability that can be offered is a boon. =A0To those, even w=
orse is
> the lack of an ABI (even for a single kernel version).  =20

Then would offering a 'stable API in disguise' not be a disaster and an=
=20
irritation to these people? If the kernel doesn't specify that an in-ke=
rnel=20
interface is stable, then there is no reason to expect it to be. It mig=
ht not=20
change, but there won't be too much sympathy for out-of-tree users if i=
t=20
does. The kernel comes with big warnings about the lack of a stable API=
 for a=20
reason.

> Another thing to consider is that the first step for many organizatio=
ns in
> opening a driver under GPL is to release a proprietary module that at=
 least
> first works. =A0

If the driver is an old-tech Linux port, then it seems there isn't too =
much=20
stopping them from doing this today (aside from the fact that some peop=
le=20
think proprietary modules are murky anyway). In this case, we don't wan=
t a=20
stable API/ABI, because then we leave them with little incentive to ope=
n the=20
code.

And if the driver is new code, they're better off doing an open driver =
from=20
the start (especially since writing a driver _for_ Linux, as opposed to=
=20
porting one, might make it count as 'derived' and hence unlawful unless=
=20
released GPL).

> Sorry for the rant.

We're not as perfect as I wish we were. But the lack of stable API (dea=
d=20
horse) is something that is fairly well established and understood. I t=
hink=20
most people feel that the cost-benefit analysis, for Linux anyway, stro=
ngly=20
favors no stable API.

Thanks,
Chase
