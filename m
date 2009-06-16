From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 21:37:57 +0200
Message-ID: <4A37F495.9030101@gmail.com>
References: <4A37A058.1030701@gmail.com>	<4A37AA0C.40507@gmail.com>	<alpine.LFD.2.01.0906161155400.3282@localhost.localdomain> <20090616.120829.182011393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, mingo@elte.hu,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37954 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbZFPTiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 15:38:18 -0400
In-Reply-To: <20090616.120829.182011393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Tue, 16 Jun 2009 11:59:34 -0700 (PDT)
>=20
>> At the very least, add a helper function for "do I actually have=20
>> outstanding allocations" or something like that. IOW, do a=20
>>
>> 	/*
>> 	 * Comment here about that magical "1"
>> 	 */
>> 	static inline int sk_has_allocations(struct sock *sk)
>> 	{
>> 		return atomic_read(&sk->sk_wmem_alloc) > 1 ||
>> 			atomic_read(&sk->sk_rmem_alloc);
>> 	}
>>
>> and then make the various network protocols use that, rather than=20
>> open-coding some random internal implementation magic.
>=20
> I agree, this should be handled with a helper function
> abstraction rather than putting "1" checks all over the place.

=46air enough, I'll submit an updated patch in following hour.

Thank you
