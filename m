From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Mon, 9 Nov 2015 09:40:45 +0800
Message-ID: <20151109014045.GA1358@gondor.apana.org.au>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
 <CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
 <CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
 <CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
 <CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
 <CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
 <CAHmME9qYAvewm6m-ex0Ds051mgDPtpmYniHzZtgM+B6seo8Cng@mail.gmail.com>
 <20151108105710.GA30282@gondor.apana.org.au>
 <CAHmME9rSGbfNFeQMCXr+0j=mSTfyxFkyLEJ0rMqnOgH6L4OSng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41280 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbKIBk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 20:40:58 -0500
Content-Disposition: inline
In-Reply-To: <CAHmME9rSGbfNFeQMCXr+0j=mSTfyxFkyLEJ0rMqnOgH6L4OSng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 08, 2015 at 03:57:24PM +0100, Jason A. Donenfeld wrote:
> On Sun, Nov 8, 2015 at 11:57 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > UDP carries no ordering information so this doesn't work.
> 
> But if there's no ordering information, what's the problem? Isn't it
> good enough to send the packets in the order they were sendto()d? Or
> in any order at all?

You're right.  I don't think the ordering matters.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
