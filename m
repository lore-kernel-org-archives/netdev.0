From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sun, 19 Sep 2004 22:02:49 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919120249.GA5963@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <E1C8way-0000aH-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 19, 2004 at 05:58:52PM +1000, Herbert Xu wrote:
> 
> Besides, for any netlink socket but the first for a process, they'll
> all have negative pid's which have nothing to do with the real pid.
> So I really think that the wake_up_process hunk is bogus.

Another reason why this is bogus.

Most kernel users of unicast have a send timeout setting of 0.  Therefore
your wake_up_process() call will never happen when netlink_attachskb is
called by the kernel.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
