From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 23:16:00 -0400
Message-ID: <1114658160.7663.102.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
	 <1114604826.7670.24.camel@localhost.localdomain>
	 <20050427233924.GA22238@gondor.apana.org.au>
	 <1114650816.7663.13.camel@localhost.localdomain>
	 <20050428012135.GA22950@gondor.apana.org.au>
	 <20050428013014.GA23043@gondor.apana.org.au>
	 <1114653140.7663.36.camel@localhost.localdomain>
	 <20050428020754.GA23326@gondor.apana.org.au>
	 <20050427194356.58a3e618.davem@davemloft.net>
	 <20050428025644.GA23823@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428025644.GA23823@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 12:56 +1000, Herbert Xu wrote:

> Well netfilter certainly follows this scheme:
> 
> $ iptables -I INPUT -s 3.3.3.3 -d 4.4.4.4 -j ACCEPT
> $ iptables -I INPUT -s 3.3.3.3 -d 4.4.4.4 -j ACCEPT
> $ iptables -v -L INPUT -n
> Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source               destination 
>     0     0 ACCEPT     all  --  *      *       3.3.3.3              4.4.4.4     
>     0     0 ACCEPT     all  --  *      *       3.3.3.3              4.4.4.4     
> 

Which is bizare to say the least. If you delete, only the first one gets
deleted.

cheers,
jamal
