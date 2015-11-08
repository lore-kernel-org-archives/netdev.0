From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: GSO with udp_tunnel_xmit_skb
Date: Sun, 8 Nov 2015 15:57:24 +0100
Message-ID: <CAHmME9rSGbfNFeQMCXr+0j=mSTfyxFkyLEJ0rMqnOgH6L4OSng@mail.gmail.com>
References: <CAHmME9pphqXyV_+LFQ6TTi4MjFB2Mopss6QQuT3YJQzvgtib2Q@mail.gmail.com>
	<CALx6S379Ma+u1rKCwyDWEHDZpQUjr9mB_YQ4=iySo9Lgga2PaQ@mail.gmail.com>
	<CAHmME9rp7ZJ_9=LHiQrO4ay_7mECj_jAmZBVHNT3Oi4uz8YxeQ@mail.gmail.com>
	<CAHo-Oowk0Sk3dp_PTnZy6+N3_MgBSxO5csezXpmbF612duSeTA@mail.gmail.com>
	<CAHmME9ptb2pwtKQ1b0yC6FBmXrvZfDKVZ8UTjGoneNw+DMuxBg@mail.gmail.com>
	<CAHo-OoxJpW+=+X6dNdLqiikeStnj4+TBoqhcSGZOSspfc4oGKQ@mail.gmail.com>
	<CAHmME9qYAvewm6m-ex0Ds051mgDPtpmYniHzZtgM+B6seo8Cng@mail.gmail.com>
	<20151108105710.GA30282@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151108105710.GA30282@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 8, 2015 at 11:57 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> UDP carries no ordering information so this doesn't work.

But if there's no ordering information, what's the problem? Isn't it
good enough to send the packets in the order they were sendto()d? Or
in any order at all?
