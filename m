From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 23:27:58 +1000
Message-ID: <20050422132758.GA22772@gondor.apana.org.au>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504221342.10675.wolfgang.walter@studentenwerk.mhn.de> <1114172084.7679.15.camel@localhost.localdomain> <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Content-Disposition: inline
In-Reply-To: <200504221522.49403.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 03:22:49PM +0200, Wolfgang Walter wrote:
> 
> I'm not sure how packets of tunnels ending at a host are treated exactly. 
> Probably the tunnel-packet itself is checked against XFRM_POLICY_IN because 
> its destination is the host itself. Then it gets decrypted if an entry 
> appropriate in the sad in (dst,spi) exists. The inner packet gets extracted 
> and decrypted and is then rerouted.

Actually it only gets checked once, after all IPsec decapsulation has been
completed.  So forwarded packets only ever get checked against the FWD
direction.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
