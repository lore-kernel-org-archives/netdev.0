From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 17:09:54 +0200
Message-ID: <1309100994.2532.35.camel@edumazet-laptop>
References: <1309097254.5134.24.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63003 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926Ab1FZPKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 11:10:03 -0400
Received: by wwe5 with SMTP id 5so4093839wwe.1
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 08:10:01 -0700 (PDT)
In-Reply-To: <1309097254.5134.24.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 juin 2011 =C3=A0 10:07 -0400, jamal a =C3=A9crit :
> Got the 10G intel cards installed finally and repeated
> the tests on both dummy and Ixgbe. The unfairness was much=20
> higher with 10G than with dummy. The logs contain the results.
>=20
> I could send another patch with stats gathering.=20
> The best place seems to be in net/softnet_stat re-using
> the fast route entries.
>=20

Hi Jamal

I would just remove the jiffies break, now we have a 64 packets limit..=
=2E

if (quota >=3D work || need_resched()) {
	...
}



