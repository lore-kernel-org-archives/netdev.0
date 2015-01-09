From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in
 the list
Date: Thu, 08 Jan 2015 19:12:20 -0800 (PST)
Message-ID: <20150108.191220.2026555103366558353.davem@davemloft.net>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
	<1420728671.5947.47.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+U0gVi1cVB4qbXAkPp1LMmNOaDOD2UaAL4riA6O_Q_SnvMQTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: kernel.org.gnu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbbAIDJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:09:28 -0500
In-Reply-To: <CA+U0gVi1cVB4qbXAkPp1LMmNOaDOD2UaAL4riA6O_Q_SnvMQTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dennis Chen <kernel.org.gnu@gmail.com>
Date: Fri, 9 Jan 2015 10:26:48 +0800

> I am very curious about the reason that you're removing the atomic ops
> in the stack, what's the benifit?

1) Do not top post.

2) The reason is, obviously, performance.
