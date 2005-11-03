From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c; kernel 2.6.14
Date: Thu, 03 Nov 2005 13:30:51 +1100
Message-ID: <E1EXUsN-0006r9-00@gondolin.me.apana.org.au>
References: <310a17ad00f84c389e64ae26656ce1a1.kjak@ispwest.com>
Cc: herbert@gondor.apana.org.au, jschlst@samba.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	acme@ghostprotocols.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030282AbVKCCb2@vger.kernel.org>
To: "Kris Katterjohn" <kjak@users.sourceforge.net>
In-Reply-To: <310a17ad00f84c389e64ae26656ce1a1.kjak@ispwest.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kris Katterjohn <kjak@ispwest.com> wrote:
> I wasn't actually changing it to add performance, but to make the code look
> cleaner. The new load_pointer() is virtually the same as having the seperate
> functions that are currently there, but the code, I think, is "better looking".
> If you look at the current net/core/filter.c and then my patched version, the
> steps are done in the exact same order and same way, but all in that one
> function.

You've just changed an out-of-line function (__load_pointer) into an
inlined function.  There may be a cost to that.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
