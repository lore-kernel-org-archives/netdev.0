From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 07:53:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919215328.GA9573@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <20040919120730.GA6005@gondor.apana.org.au> <414DF111.3080409@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414DF111.3080409@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 10:50:25PM +0200, Pablo Neira wrote:
>
> yes, you are totally right, but as I told you before, I'm not focusing 
> my efforts in improving netlink sockets for tools like iproute, for 
> those MSG_DONTWAIT is fairly ok.

No I'm talking not about iproute, I'm talking the kernel callers of
unicast/broadcast.  They never wait.
 
> I don't agree, enlarging the queue size for applications that send a lot 
> of information in a short period of time is just a workaround.

Workaround for what? Please define your problem.

Your original message mentioned a dead-lock, which is now obviously
non-existant.

> Herbert, I don't agree, my patch isn't related to stuff that you've 
> mentioned. It's fairly true that most ?of application use socket timeout 
> 0, but my patch is not for those! :-) well, still disagree?

Please reread my messages.  I'm not talking about user-space applications
setting timeout to 0.  Most of them don't.

I'm talking about every single kernel netlink sender.  They never wait.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
