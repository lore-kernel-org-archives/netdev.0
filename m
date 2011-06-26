From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 18:26:39 +0200
Message-ID: <1309105599.2532.50.camel@edumazet-laptop>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
	 <1309102334.5134.31.camel@mojatatu>  <1309104215.5134.37.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56432 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194Ab1FZQ0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 12:26:47 -0400
Received: by wyg8 with SMTP id 8so663563wyg.19
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 09:26:45 -0700 (PDT)
In-Reply-To: <1309104215.5134.37.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 juin 2011 =C3=A0 12:03 -0400, jamal a =C3=A9crit :
> Updated version of the patch with feedback from Ben and Eric.
>=20

Difficult to discuss about your patch because you didnt inline it :-(

You should remove this line in the comment

+                * 3. we've been doing it for too long.




