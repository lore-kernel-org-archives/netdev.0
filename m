From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] neigh: Store hash shift instead of mask.
Date: Mon, 11 Jul 2011 14:08:28 -0700 (PDT)
Message-ID: <20110711.140828.1179960343630781204.davem@davemloft.net>
References: <20110711.014841.1004194674075047305.davem@davemloft.net>
	<CAHXqBFLk5ze9y7htyO+9z7=qcznNjXeuJK5Rs1t2ym=vLqDy5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@purestorage.com, johnwheffner@gmail.com, mj@ucw.cz,
	netdev@vger.kernel.org
To: mirqus@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab1GKVIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 17:08:43 -0400
In-Reply-To: <CAHXqBFLk5ze9y7htyO+9z7=qcznNjXeuJK5Rs1t2ym=vLqDy5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirqus@gmail.com>
Date: Mon, 11 Jul 2011 13:58:41 +0200

> 2011/7/11 David Miller <davem@davemloft.net>:
>> And mask the hash function result by simply shifting
>> down the "->hash_shift" most significant bits.
>>
>> Currently which bits we use is arbitrary since jhash
>> produces entropy evenly across the whole hash function
>> result.
>>
>> But soon we'll be using universal hashing functions,
>> and in those cases more entropy exists in the higher
>> bits than the lower bits, because they use multiplies.
>=20
> You could use some evil shift tricks to cut some instructions if you =
like. ;-)

If these were fast paths I would seriously consider it :-)

But they really are not.
