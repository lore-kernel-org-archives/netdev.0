From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sun, 8 Nov 2015 18:57:10 +0800
Message-ID: <20151108105710.GA30282@gondor.apana.org.au>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
 <CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
 <CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
 <CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
 <CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
 <CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
 <CAHmME9qYAvewm6m-ex0Ds051mgDPtpmYniHzZtgM+B6seo8Cng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53555 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbbKHK5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 05:57:46 -0500
Content-Disposition: inline
In-Reply-To: <CAHmME9qYAvewm6m-ex0Ds051mgDPtpmYniHzZtgM+B6seo8Cng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 08, 2015 at 11:36:53AM +0100, Jason A. Donenfeld wrote:
>
> Wouldn't there be some significant savings from bundling together
> several UDP packets meant for the same destination, and sending those
> all as one super-packet, so they don't each have to traverse the whole
> networking and netfilter stack? By asking that question, it doesn't
> feel as though I've come up with a new idea; is there a reason why
> that isn't implemented or why (if) it was rejected?

UDP carries no ordering information so this doesn't work.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
