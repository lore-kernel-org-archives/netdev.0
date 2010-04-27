From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 27 Apr 2010 23:55:33 +0800
Message-ID: <20100427155533.GA5709@gondor.apana.org.au>
References: <20100422.004324.67422011.davem@davemloft.net> <20100422142506.GA15858@gondor.apana.org.au> <20100422154908.GA31568@midget.suse.cz> <20100422.185400.71096585.davem@davemloft.net> <20100427155034.GA11157@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42880 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752094Ab0D0Pzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 11:55:44 -0400
Content-Disposition: inline
In-Reply-To: <20100427155034.GA11157@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 05:50:34PM +0200, Jiri Bohac wrote:
>
>   I think that what Herbert is doing is only going to enforce that
>   the ip6_del_rt() is never going to fail, so the dst_free()
>   won't ever be called anyway, right?

Yes I think you're right.  But let's fix the bigger problem first,
and then we can audit this and possibly turn it into a WARN_ON.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
