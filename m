From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [5/*] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: Mon, 11 Apr 2005 14:45:36 +0900
Message-ID: <425A0F00.8070509@linux-ipv6.org>
References: <1112702604.1089.119.camel@jzny.localdomain>	 <20050409105452.GA7171@gondor.apana.org.au>	 <20050409111244.GB7171@gondor.apana.org.au>	 <20050409111551.GA7378@gondor.apana.org.au>	 <20050410074849.GA13259@gondor.apana.org.au>	 <20050410090250.GA26022@gondor.apana.org.au> <1113142510.1091.294.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1113142510.1091.294.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Do you have anymore patches? If not i can give these a quick test;
> Masahide has a better test setup and if he has time he should as well.

I can, but about 24 hours later. I'll test it there is no update and
if it isn't too late then.

Thanks,

-- 
Masahide NAKAMURA


jamal wrote:
> On Sun, 2005-04-10 at 05:02, Herbert Xu wrote:
> 
>>Hi:
>>
>>I spotted some more issues while preparing the last patch of the
>>series.  So I'll extend it a little further.
>>
>>This patch removes XFRM_SAP_* and converts them over to XFRM_MSG_*.
>>The netlink interface is meant to map directly onto the underlying
>>xfrm subsystem.  Therefore rather than using a new independent
>>representation for the events we can simply use the existing ones
>>from xfrm_user.
>>
> 
> 
> The main reason i did the XFRM_SAP_* is to be able to cover a case where
> a message was relevant to one KM but not the other. That may not
> exist now (actually it does with policy expiration that pfkey cant
> handle - but thats easy to take care of).
> Hopefully XFRM_MSG_xxx is the superset and will be sufficient.
> 
> Do you have anymore patches? If not i can give these a quick test;
> Masahide has a better test setup and if he has time he should as well.
> 
> cheers,
> jamal
> 
> 
