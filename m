From: jamal <hadi@cyberus.ca>
Subject: Re: [5/*] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: 10 Apr 2005 10:15:11 -0400
Message-ID: <1113142510.1091.294.camel@jzny.localdomain>
References: <1112702604.1089.119.camel@jzny.localdomain>
	 <20050409105452.GA7171@gondor.apana.org.au>
	 <20050409111244.GB7171@gondor.apana.org.au>
	 <20050409111551.GA7378@gondor.apana.org.au>
	 <20050410074849.GA13259@gondor.apana.org.au>
	 <20050410090250.GA26022@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050410090250.GA26022@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-10 at 05:02, Herbert Xu wrote:
> Hi:
> 
> I spotted some more issues while preparing the last patch of the
> series.  So I'll extend it a little further.
> 
> This patch removes XFRM_SAP_* and converts them over to XFRM_MSG_*.
> The netlink interface is meant to map directly onto the underlying
> xfrm subsystem.  Therefore rather than using a new independent
> representation for the events we can simply use the existing ones
> from xfrm_user.
> 

The main reason i did the XFRM_SAP_* is to be able to cover a case where
a message was relevant to one KM but not the other. That may not
exist now (actually it does with policy expiration that pfkey cant
handle - but thats easy to take care of).
Hopefully XFRM_MSG_xxx is the superset and will be sufficient.

Do you have anymore patches? If not i can give these a quick test;
Masahide has a better test setup and if he has time he should as well.

cheers,
jamal
