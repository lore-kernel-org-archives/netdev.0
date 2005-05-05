From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] add open iscsi netlink interface to iscsi transport class
Date: Thu, 05 May 2005 21:39:47 +1000
Message-ID: <E1DTehn-0005gJ-00@gondolin.me.apana.org.au>
References: <20050505.185503.78606493.yoshfuji@linux-ipv6.org>
Cc: michaelc@cs.wisc.edu, linux-scsi@vger.kernel.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20050505.185503.78606493.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> In article <42798AC1.2010308@cs.wisc.edu> (at Wed, 04 May 2005 19:53:53 -0700), Mike Christie <michaelc@cs.wisc.edu> says:
> 
>> +struct iscsi_uevent {
> :
>> +} __attribute__ ((aligned (sizeof(unsigned long))));
> 
> I think it'd be better to use sizeof(uint64_t) or something.

Is there a benefit in aligning on 64-bit boundaries for 32-bit platforms?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
