From: "Kris Katterjohn" <kjak@ispwest.com>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
Date: Wed, 2 Nov 2005 18:48:59 -0800
Message-ID: <3dd4936961ae4324937d19838bad898b.kjak@ispwest.com>
Reply-To: "Kris Katterjohn" <kjak@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: jschlst@samba.org, torvalds@osdl.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030286AbVKCCtD@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forgive me because this is one of my first attempts at anything related to the
kernel, but...

1) How would I go about benchmarking this?
2) If the out-of-line code is executed anyway (since load_pointer() calls __load_pointer()),
would it really effect it very much?

I've been programming as a hobby for a few years, but I never really worried
about inlining my code. Most likely because when I was learning C, I was using
books etc. that were written before C99 was out.

Thanks


----- Original Message -----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
> Kris Katterjohn <kjak@ispwest.com> wrote:
> > I wasn't actually changing it to add performance, but to make the code look
> > cleaner. The new load_pointer() is virtually the same as having the seperate
> > functions that are currently there, but the code, I think, is "better looking".
> > If you look at the current net/core/filter.c and then my patched version, the
> > steps are done in the exact same order and same way, but all in that one
> > function.
> 
> You've just changed an out-of-line function (__load_pointer) into an
> inlined function.  There may be a cost to that.
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
