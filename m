From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] pkt_sched: gen_estimator: kill
	est_lock rwlock
Date: Tue, 8 Jun 2010 12:40:52 +0000
Message-ID: <20100608124052.GB9392@ff.dom.local>
References: <20100608121546.GA9392@ff.dom.local> <1276000052.2475.307.camel@edumazet-laptop>
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
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48549 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406Ab0FHMky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 08:40:54 -0400
Received: by fxm8 with SMTP id 8so2841143fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 05:40:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276000052.2475.307.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 02:27:32PM +0200, Eric Dumazet wrote:
> Le mardi 08 juin 2010 ?? 12:15 +0000, Jarek Poplawski a =E9crit :
>=20
> >=20
> > Actually, I guess, Changli meant the bug introduced by your previou=
s
> > patch by removing the est_lock. With this lock (and your commit 5d9=
44)
> > bstats (and API) seem "fundamentaly" safe.
> >=20
>=20
> Sorry, I have no idea of what you want to say, I cant find commit 5d9=
44.
>=20

Sorry, I meant the commit mentioned in your changelog which was quoted.

> This was partially addressed in commit 5d944c640b4 (gen_estimator:
> deadlock fix), but same problem exist for all gen_kill_estimator()
> users.

Jarek P.
