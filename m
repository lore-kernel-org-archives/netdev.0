From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 23:53:07 +1000
Message-ID: <20050422135307.GA2667@gondor.apana.org.au>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de> <20050422132758.GA22772@gondor.apana.org.au> <200504221548.44560.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Content-Disposition: inline
In-Reply-To: <200504221548.44560.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 03:48:43PM +0200, Wolfgang Walter wrote:
> 
> So linux implements things like i.e. ipcomp in esp-tunnel in ah-tunnel as 
> bundle instead of feeding it for every transformation into the packet receive 
> code again? I assume that incoming packets which are subject to several 
> ipsec-transformations are exactly seen twice in netfilter PREROUTING: first 
> before decapsulation and then after complete decapsulation?

The packet is fed into each transform as you would expect.  However,
the policy check is done only once at the very end (unless raw sockets
are involved in which case it can occur multiple times).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
