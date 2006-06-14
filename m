From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 18:31:12 -0600
Message-ID: <20060613183112.B8460@openss7.org>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <448F3C83.9080606@google.com> <20060613164714.B7232@openss7.org> <200606131859.43695.chase.venters@clientec.com>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:60082 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S932374AbWFNAbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 20:31:13 -0400
To: Chase Venters <chase.venters@clientec.com>
Content-Disposition: inline
In-Reply-To: <200606131859.43695.chase.venters@clientec.com>; from chase.venters@clientec.com on Tue, Jun 13, 2006 at 06:59:21PM -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chase,

On Tue, 13 Jun 2006, Chase Venters wrote:
>=20
> It depends on what you mean by "pure-BSD". If you're talking about th=
e=20
> 4-clause license with the advertising clause, then you are correct. O=
therwise=20
> (IANAL) but my understanding is that BSD code can even be relicensed =
GPL by a=20
> third party contribution (though it is perhaps kind to ask for relice=
nsing=20
> permission anyway).

Yes, and the long list of open source licenses listed on the FSF websit=
e
as incompatible with the GPL.

> Then would offering a 'stable API in disguise' not be a disaster and =
an=20
> irritation to these people? If the kernel doesn't specify that an in-=
kernel=20
> interface is stable, then there is no reason to expect it to be. It m=
ight not=20
> change, but there won't be too much sympathy for out-of-tree users if=
 it=20
> does. The kernel comes with big warnings about the lack of a stable A=
PI for a=20
> reason.

In fact most core kernel facilities (spin lock, memory caches, characte=
r and
block device interface, even core file system) have had a very stable A=
PI
(way back to early 2.4 kernels).  An in fact most of them are derived f=
rom
some variant or precursor to UNIX.  For example, memory caches are a Su=
n
Solaris concept.

It is the lack of an ABI that is most frustrating to these users.

>=20
> > Another thing to consider is that the first step for many organizat=
ions in
> > opening a driver under GPL is to release a proprietary module that =
at least
> > first works. =A0
>=20
> If the driver is an old-tech Linux port, then it seems there isn't to=
o much=20
> stopping them from doing this today (aside from the fact that some pe=
ople=20
> think proprietary modules are murky anyway). In this case, we don't w=
ant a=20
> stable API/ABI, because then we leave them with little incentive to o=
pen the=20
> code.

"old-tech"?  No, these are high-tech drivers supported by commercial RT=
OS,
from which Linux stands to benefit.  And, by not allowing these organiz=
ations
to take the first step (generate a workable Linux driver) such a policy
provides them little incentive to ever move the driver to Linux, and cu=
ts
them off from opening it.

I don't think that it is fair to say that an unstable API/ABI, in of it=
self,
provides an incentive to open an existing proprietary driver.

> We're not as perfect as I wish we were. But the lack of stable API (d=
ead=20
> horse) is something that is fairly well established and understood. I=
 think=20
> most people feel that the cost-benefit analysis, for Linux anyway, st=
rongly=20
> favors no stable API.

Well, the lack of a stable ABI is well known.  The API is largely stabl=
e (but
not sacrosanctly so) for the major reason that changing it within a lar=
ge
code base is difficult and error prone at best.
