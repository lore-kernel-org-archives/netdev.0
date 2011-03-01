From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 17:31:24 +0100
Message-ID: <1298997084.3284.119.camel@edumazet-laptop>
References: <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301115305.GA6984@gondor.apana.org.au>
	 <1298984609.3284.98.camel@edumazet-laptop>
	 <20110301131823.GB8028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60395 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468Ab1CAQfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 11:35:45 -0500
Received: by fxm17 with SMTP id 17so4978207fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 08:35:43 -0800 (PST)
In-Reply-To: <20110301131823.GB8028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 21:18 +0800, Herbert Xu a =C3=A9crit :
> On Tue, Mar 01, 2011 at 02:03:29PM +0100, Eric Dumazet wrote:
> >
> > I believe its now done properly (in net-next-2.6) with commit
> > 4f57c087de9b46182 (net: implement mechanism for HW based QOS)
>=20
> Nope, that has nothing to do with this.

Right, I was thinking of commit 1d24eb4815d1e0e8 (xps: Transmit Packet
Steering)

Now you say all this stuff should be replaced by "use this cpu number
nly", just because you have a multi threaded process sending UDP frames
trough one socket...

This wont work for tcp streams, you could imagine a multi-threaded
application using a shared tcp socket as well. Too many OOO packets.



