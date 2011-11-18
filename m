From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH FIX net-next v1] net-forcedeth: fix possible stats
 inaccuracies on 32b hosts
Date: Fri, 18 Nov 2011 02:09:21 -0500 (EST)
Message-ID: <20111118.020921.1221623749729939203.davem@davemloft.net>
References: <cover.1321558587.git.david.decotigny@google.com>
	<34add86253ddd91d5d4d4c7fee9c90f63a8d8edf.1321558587.git.david.decotigny@google.com>
	<1321560495.2444.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: david.decotigny@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ian.campbell@citrix.com,
	rick.jones2@hp.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321560495.2444.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Nov 2011 21:08:15 +0100

> Le jeudi 17 novembre 2011 =E0 11:38 -0800, David Decotigny a =E9crit =
:
>> The software stats are updated from BH, this change ensures that 32b
>> UP hosts use appropriate protection.
>>=20
>> Tested:
>>   - HW/SW stats consistent with pktgen (in particular tx=3Drx)
>>   - HW/SW stats consistent when tx/rx offloads disabled
>>   - no problem with+without lockdep (SMP 16-way)
>>=20
>>=20
>>=20
>> Signed-off-by: David Decotigny <david.decotigny@google.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
