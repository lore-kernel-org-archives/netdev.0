From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 10:54:48 +1000
Message-ID: <20050422005448.GA10819@gondor.apana.org.au>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de> <20050421214618.GA29991@gondor.apana.org.au> <1114127419.10572.4.camel@localhost.localdomain> <20050421235802.GB10451@gondor.apana.org.au> <1114129099.10572.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114129099.10572.24.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2005 at 08:18:19PM -0400, jamal wrote:
>
> So i was wondering whether they OUT shouldnt be just a duplicate of 
> FWD (instead FWD seems to be the dup of IN). Look at that sample i
> posted - all his policies look like that. What gives? Why are the IN and
> FWD exactly the same? bug in racoon/setkey?

FWD checks inbound IPsec policies while OUT determines the outbound
IPsec policies.

The IN direction is not used at all for forwarded packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
