From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 13:35:36 -0700 (PDT)
Message-ID: <20110708.133536.2096604131639797895.davem@davemloft.net>
References: <20110708.125912.1535057393082512441.davem@davemloft.net>
	<CAHXqBFL6fT2V0iFTN1mJmQjEVUEfGEAQVOS=Y46BREUr_KWoow@mail.gmail.com>
	<CAHXqBFKKRXFjr7y+v12ApuWTpjf-G3H5iBtfQg1gzC5iPfRO=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085Ab1GHUfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 16:35:47 -0400
In-Reply-To: <CAHXqBFKKRXFjr7y+v12ApuWTpjf-G3H5iBtfQg1gzC5iPfRO=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Fri, 8 Jul 2011 22:34:22 +0200

> BTW, am I correct, that neighbour hash tables never shrink? Looking a=
t
> net/core/neighbour.c it seems that after the table reaches gc_thresh3
> capacity, it is never reallocated again.

Currently, yes, but I plan to remove that limit.
