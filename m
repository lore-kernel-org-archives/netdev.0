From: Patrick McHardy <kaber@trash.net>
Subject: Re: Checking SPI in xfrm_state_find
Date: Sun, 03 Apr 2005 19:00:36 +0200
Message-ID: <42502134.8030003@trash.net>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net> <20050331004658.GA26395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050331004658.GA26395@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> It just occured to me that it would be much simpler if you did the
> existence check in the first loop.
> 
> So something like
> 
> 		if (x->props.family != family ||
> 		    !xfrm_state_addr_check(x, daddr, saddr, family) ||
> 		    tmpl->id.proto == x->id.proto)
> 			continue;
> 		if (tmpl->id.spi) {
> 			if (tmpl->id.spi != x->id.spi)
> 				continue;
> 			error = -EEXIST;
> 		}
> 		if (x->props.reqid == tmpl->reqid &&
> 		    tmpl->mode == x->props.mode) {
> 		}

You're right, sorry for getting back to you so late. But since its
already in now and not very important, I'm going to leave it until
I have a better reason to touch that code, if you're ok with that.

Regards
Patrick
