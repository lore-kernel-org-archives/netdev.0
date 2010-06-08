From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill est_lock
 rwlock
Date: Tue, 08 Jun 2010 21:29:50 +0200
Message-ID: <4C0E9A2E.9080109@gmail.com>
References: <20100608121546.GA9392@ff.dom.local> <1276000052.2475.307.camel@edumazet-laptop> <20100608124052.GB9392@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:58236 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab0FHT36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 15:29:58 -0400
Received: by fg-out-1718.google.com with SMTP id d23so2240844fga.1
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 12:29:57 -0700 (PDT)
In-Reply-To: <20100608124052.GB9392@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 06/08/2010 02:40 PM:

> On Tue, Jun 08, 2010 at 02:27:32PM +0200, Eric Dumazet wrote:
>> Le mardi 08 juin 2010 ?? 12:15 +0000, Jarek Poplawski a =E9crit :
>>
>>> Actually, I guess, Changli meant the bug introduced by your previou=
s
>>> patch by removing the est_lock. With this lock (and your commit 5d9=
44)
>>> bstats (and API) seem "fundamentaly" safe.
>>>
>> Sorry, I have no idea of what you want to say, I cant find commit 5d=
944.
>>
>=20
> Sorry, I meant the commit mentioned in your changelog which was quote=
d.
>=20
>> This was partially addressed in commit 5d944c640b4 (gen_estimator:
>> deadlock fix), but same problem exist for all gen_kill_estimator()
>> users.

In case it's still unclear, I wanted to say that IMHO this patch's
title and changelog are misleading because most of its content are
est_lock to RCU changes - not fixes.

>> [PATCH net-next-2.6] pkt_sched: gen_kill_estimator() rcu fixes
>>=20
>> gen_kill_estimator() API is fundamentaly wrong, since caller should =
make
>> sure an RCU grace period is respected before freeing bstats or lock.

=46reeing bstats doesn't currently require RCU protection.

Jarek P.
