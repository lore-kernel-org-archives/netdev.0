From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4] Always set hoplimit
Date: Wed, 19 Nov 2003 12:08:27 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119010827.GA25593@gondor.apana.org.au>
References: <20031113110438.GA29522@gondor.apana.org.au> <20031118165909.788d5388.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031118165909.788d5388.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 18, 2003 at 04:59:09PM -0800, David S. Miller wrote:
>
> Did you run into an actual problem that led you to this issue?  If
> so, what was it?  Or was this just determined by pure code review?

Someone reported this problem to me after a picky firewall complained
about getting broadcast packets with ttl == 0.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
