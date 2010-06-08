From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
 est_lock rwlock
Date: Tue, 08 Jun 2010 21:45:29 +0200
Message-ID: <1276026329.2439.2.camel@edumazet-laptop>
References: <20100608121546.GA9392@ff.dom.local>
	 <1276000052.2475.307.camel@edumazet-laptop>
	 <20100608124052.GB9392@ff.dom.local>  <4C0E9A2E.9080109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:33365 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab0FHTpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 15:45:34 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1571613fgb.1
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 12:45:33 -0700 (PDT)
In-Reply-To: <4C0E9A2E.9080109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 21:29 +0200, Jarek Poplawski a =C3=A9crit =
:
> Jarek Poplawski wrote, On 06/08/2010 02:40 PM:
>=20
> > On Tue, Jun 08, 2010 at 02:27:32PM +0200, Eric Dumazet wrote:
> >> Le mardi 08 juin 2010 ?? 12:15 +0000, Jarek Poplawski a =C3=A9crit=
 :
> >>
> >>> Actually, I guess, Changli meant the bug introduced by your previ=
ous
> >>> patch by removing the est_lock. With this lock (and your commit 5=
d944)
> >>> bstats (and API) seem "fundamentaly" safe.
> >>>
> >> Sorry, I have no idea of what you want to say, I cant find commit =
5d944.
> >>
> >=20
> > Sorry, I meant the commit mentioned in your changelog which was quo=
ted.
> >=20
> >> This was partially addressed in commit 5d944c640b4 (gen_estimator:
> >> deadlock fix), but same problem exist for all gen_kill_estimator()
> >> users.
>=20
> In case it's still unclear, I wanted to say that IMHO this patch's
> title and changelog are misleading because most of its content are
> est_lock to RCU changes - not fixes.
>=20

=2E..

> >> [PATCH net-next-2.6] pkt_sched: gen_kill_estimator() rcu fixes
> >>=20
> >> gen_kill_estimator() API is fundamentaly wrong, since caller shoul=
d make
> >> sure an RCU grace period is respected before freeing bstats or loc=
k.
>=20
> Freeing bstats doesn't currently require RCU protection.
>=20
> Jarek P.

So what ? No changes needed ?

I am really lost by your comments Jarek.

Maybe you could provide an alternative patch, so that we can make some
progress ?



