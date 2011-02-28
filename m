From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 15:22:06 +0100
Message-ID: <1298902926.2941.349.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <1298899971.2941.281.camel@edumazet-laptop>
	 <20110228141327.GA22851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59348 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476Ab1B1OXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 09:23:11 -0500
Received: by fxm17 with SMTP id 17so3766082fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 06:23:10 -0800 (PST)
In-Reply-To: <20110228141327.GA22851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 22:13 +0800, Herbert Xu a =C3=A9cr=
it :
> On Mon, Feb 28, 2011 at 02:32:51PM +0100, Eric Dumazet wrote:
> >
> > Now, input path can run without finding socket locked by xmit path,=
 so
> > skb are queued into receive queue, not backlog one.
>=20
> Indeed, I think this is what Dave alluded to earlier.  This will
> eventually have to be dealt with but for now the data rate is low
> enough that it isn't killing us.

Not sure how you read this ;)

I said that before your patches, a sender was consuming lot of time to
transfert frames from backlog to receive queue right before releasing
socket lock.

Now, the receive path doesnt slow down the senders, and vice versa.

:)


