From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 02 Mar 2011 09:24:37 +0100
Message-ID: <1299054277.2930.89.camel@edumazet-laptop>
References: <20110301115305.GA6984@gondor.apana.org.au>
	 <1298984609.3284.98.camel@edumazet-laptop>
	 <20110301131823.GB8028@gondor.apana.org.au>
	 <1298997084.3284.119.camel@edumazet-laptop>
	 <20110302002353.GA15009@gondor.apana.org.au>
	 <1299031203.2930.26.camel@edumazet-laptop>
	 <20110302023920.GA16072@gondor.apana.org.au>
	 <AANLkTim0+7mTYrQF3mttUW+JqOmvTyMoDXOdeCX_SSdp@mail.gmail.com>
	 <20110302073123.GA18443@gondor.apana.org.au>
	 <1299053048.2930.85.camel@edumazet-laptop>
	 <20110302080723.GA18773@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35287 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab1CBIYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 03:24:44 -0500
Received: by fxm17 with SMTP id 17so5654137fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 00:24:43 -0800 (PST)
In-Reply-To: <20110302080723.GA18773@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 16:07 +0800, Herbert Xu a =C3=A9crit :
> On Wed, Mar 02, 2011 at 09:04:08AM +0100, Eric Dumazet wrote:
> >=20
> > Not sure why two UDP packets from the same cpu should be sent on sa=
me
> > queue.
> >=20
> > - Some qdisc do reorder packets anyway.
>=20
> Which qdisc reorders packets belonging to the same flow?
>=20

Hmm to be fair you did not specified "same flow", and /sbin/named
answers are usually one packet long...

How are we going to detect flows in sendto() calls ?

Just kidding.

If you want to push your patch, I suspect a dynamic per_cpu variable is
needed per TX-multiqueue device, so that "current cpu -> txq number" is
one instruction.



