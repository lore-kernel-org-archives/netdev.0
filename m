From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 03 Jul 2009 17:37:31 +0200
Message-ID: <4A4E25BB.8060408@gmail.com>
References: <20090703152951.GA28837@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, mingo@elte.hu,
	jolsa@redhat.com, a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, eric.dumazet@gmail.com,
	Paul.McKenney@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44354 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407AbZGCPiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 11:38:10 -0400
In-Reply-To: <20090703152951.GA28837@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
>> Why don't we create a read_lock without acquire semantic instead (e.=
g.
>> read_lock_nomb(), or something with a better name like __read_lock()=
) ?
>> On architectures where memory barriers are needed to provide the acq=
uire
>> semantic, it would be faster to do :
>>
>> __read_lock();
>> smp_mb();
>>
>> than :
>>
>> read_lock(); <- e.g. lwsync + isync or something like that
>> smp_mb(); <- full sync.
>=20
> Hmm, why do we even care when read_lock should just die?
>=20
> Cheers,

+1 :)

Do you mean using a spinlock instead or what ?

Also, how many arches are able to have a true __read_lock()
(or __spin_lock() if that matters), without acquire semantic ?
