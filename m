From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
 est_lock rwlock
Date: Tue, 8 Jun 2010 22:24:05 +0200
Message-ID: <20100608202405.GA3496@del.dom.local>
References: <20100608121546.GA9392@ff.dom.local>
 <1276000052.2475.307.camel@edumazet-laptop>
 <20100608124052.GB9392@ff.dom.local>
 <4C0E9A2E.9080109@gmail.com>
 <1276026329.2439.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:58277 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217Ab0FHUYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 16:24:20 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1584221fgb.1
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 13:24:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276026329.2439.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 09:45:29PM +0200, Eric Dumazet wrote:
> Le mardi 08 juin 2010 ?? 21:29 +0200, Jarek Poplawski a =E9crit :
> > Jarek Poplawski wrote, On 06/08/2010 02:40 PM:
> >=20
> > > On Tue, Jun 08, 2010 at 02:27:32PM +0200, Eric Dumazet wrote:
> > >> Le mardi 08 juin 2010 ?? 12:15 +0000, Jarek Poplawski a =E9crit =
:
> > >>
> > >>> Actually, I guess, Changli meant the bug introduced by your pre=
vious
> > >>> patch by removing the est_lock. With this lock (and your commit=
 5d944)
> > >>> bstats (and API) seem "fundamentaly" safe.
> > >>>
> > >> Sorry, I have no idea of what you want to say, I cant find commi=
t 5d944.
> > >>
> > >=20
> > > Sorry, I meant the commit mentioned in your changelog which was q=
uoted.
> > >=20
> > >> This was partially addressed in commit 5d944c640b4 (gen_estimato=
r:
> > >> deadlock fix), but same problem exist for all gen_kill_estimator=
()
> > >> users.
> >=20
> > In case it's still unclear, I wanted to say that IMHO this patch's
> > title and changelog are misleading because most of its content are
> > est_lock to RCU changes - not fixes.
> >=20
>=20
> ...
>=20
> > >> [PATCH net-next-2.6] pkt_sched: gen_kill_estimator() rcu fixes
> > >>=20
> > >> gen_kill_estimator() API is fundamentaly wrong, since caller sho=
uld make
> > >> sure an RCU grace period is respected before freeing bstats or l=
ock.
> >=20
> > Freeing bstats doesn't currently require RCU protection.
> >=20
> > Jarek P.
>=20
> So what ? No changes needed ?

Such a changelog is a documentation for future, just like this one,
crucial for this suject:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D0929c2dd83317813425b937fbc0041013b8685ff

There is no reason to make people (our?) life harder with describing
unexistent bugs.

>=20
> I am really lost by your comments Jarek.
>=20
> Maybe you could provide an alternative patch, so that we can make som=
e
> progress ?
>=20

No, I only meant fixing the title and changelog if you have any problem
with separating it for two parts.

Jarek P.
