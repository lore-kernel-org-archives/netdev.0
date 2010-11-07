From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 18:40:34 +0100
Message-ID: <1289151634.2478.191.camel@edumazet-laptop>
References: <1289147492.3090.137.camel@Dan>
	 <1289149416.2478.143.camel@edumazet-laptop> <1289150714.3090.158.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44254 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab0KGRkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 12:40:40 -0500
Received: by wyb36 with SMTP id 36so2707652wyb.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 09:40:38 -0800 (PST)
In-Reply-To: <1289150714.3090.158.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 novembre 2010 =C3=A0 12:25 -0500, Dan Rosenberg a =C3=A9=
crit :
> > NACK
> >=20
> > Thats a pretty stupid patch series, sorry.
> >=20
>=20
> I think it might be more constructive to avoid childish name-calling =
and
> instead try to guide the conversation in a way that produces a patch
> that would better fit your needs.  Even if you don't agree with the
> approach, it's certainly not "stupid".
>=20

It is stupid. Really Dan. The idea is stupid, not you.

> > You are basically ruining a lot of debugging facilities we use ever=
y day
> > to find and fix _real_ bugs. The bugs that happen to crash machines=
 of
> > our customers.
>=20
> I'm going to give you the benefit of the doubt and assume you're not
> implying that security issues aren't "real" bugs, because that would =
be
> utterly ridiculous.
>=20

So what ? Because of security, we must accept even stupid patches ?

> >=20
> > If you want to avoid a user reading kernel syslog, why dont you fix=
 the
> > problem for non root users able to "dmesg" ? I personally dont care=
=2E
> >=20
>=20
> This is simply the reality of the current situation.  At least while =
the
> kernel syslog is available to unprivileged users, we need to be more
> careful of what is visible through there.
>=20

So instead of fixing the problem, you are going to change thousand of
kernel printk() ?

> > I am a root user on my machine, I _want_ to have some pretty basic
> > informations so that I can work on it, and I believe my work is use=
ful.
> >=20
> > There are pretty easy ways to not disclose "information", but your =
way
> > of using '0' for all values is the dumbest idea one could ever had.
>=20
> I'm glad I'm capable of producing "the dumbest idea one could ever ha=
d".
> You seem to be quite set on convincing unpaid volunteers such as myse=
lf
> to stop sending in patches.
>=20

I am unpaid volunteer too.

I also had stupid ideas, and other guys said so.

So what ? Should I continue contributing to Linux, or assume I am stupi=
d
and stop ?

> >=20
> > A single XOR with a "root only visible, random value chosen at boot=
"
> > would be OK. At least we could continue our work, with litle burden=
=2E
>=20
> Finally, a useful contribution.  I'll consider this option after hear=
ing
> from a few more people on the subject.

I am glad you like it. But it also may a _very_ stupid idea. You really
want to have a _lot_ of agreement before even considering it.




