From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Mon, 26 Oct 2009 12:01:42 +0300
Message-ID: <200910261101.43099.cratiu@ixiacom.com>
References: <200910251954.49700.opurdila@ixiacom.com> <4AE4C50F.7060605@gmail.com> <200910260021.48785.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19581 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755383AbZJZJBk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 05:01:40 -0400
In-Reply-To: <200910260021.48785.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 October 2009 00:21:48 Octavian Purdila wrote:
> On Sunday 25 October 2009 23:37:19 you wrote:
> > Octavian Purdila a =C3=A9crit :
> > > RFC patches are attached.
> > >
> > > Another possible approach: add an interface flag and use it to de=
cide
> > > whether we want per interface sysctl entries or not.
> >
> > Hmm, could we speedup sysctl instead, adding rbtree or something ?
>=20
> Very good point, I think this is the best solution for people using a
> moderately high number of interfaces (a few thousand).
>=20
> But for really large setups there is another issue: memory consumptio=
n. In
> fact, in order to be able to scale to 128K interfaces and still have =
a
> significant amount of memory available to applications we also had to
>  disable sysfs and #ifdef CONFIG_SYSFS struct device from net_device.
>=20
> I would also argue that when you have such a large number of interfac=
es you
> don't need to change setting on a per interface basis. Or at least th=
is is
>  our case :)  and I suspect that the case with a large number of PPP
>  interfaces is similar.
>=20

Another possible approach: shared settings for an interface group. If y=
ou have=20
a large number of interfaces of the same type it would be nice if you c=
ould=20
change some setting for the whole group instead of globally or individu=
ally.=20

Is this approach feasible anyway? Or I'm talking rubbish.

Cosmin.
