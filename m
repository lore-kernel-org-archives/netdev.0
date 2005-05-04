From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC] Store idev entries
Date: Wed, 04 May 2005 03:23:29 +0200
Message-ID: <42782411.2070206@trash.net>
References: <4272EC95.20401@miyazawa.org> <20050430.120736.45974367.yoshfuji@linux-ipv6.org> <20050430031159.GA24326@gondor.apana.org.au> <20050430082339.GA20338@gondor.apana.org.au> <20050430114349.GA24573@gondor.apana.org.au> <20050503162628.7541807d.davem@davemloft.net> <42782025.3010700@trash.net> <20050504011204.GA19740@gondor.apana.org.au> <20050504011956.GA20670@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050504011956.GA20670@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
>>Hmm, I wonder why I didn't see this.  Anyway, could you please add
>>the include to addrconf.h instead?
> 
> Aha, I can see it if I do something like this.
> 
> 
> ------------------------------------------------------------------------
> 
> ===== include/asm-i386/checksum.h 1.14 vs edited =====
> --- 1.14/include/asm-i386/checksum.h	2005-01-16 22:58:42 +11:00
> +++ edited/include/asm-i386/checksum.h	2005-05-04 11:17:09 +10:00
> @@ -1,8 +1,6 @@
>  #ifndef _I386_CHECKSUM_H
>  #define _I386_CHECKSUM_H
>  
> -#include <linux/in6.h>
> -
>  /*
>   * computes the checksum of a memory block at buff, length len,
>   * and adds in "sum" (32-bit)
> @@ -145,6 +143,7 @@
>  }
>  
>  #define _HAVE_ARCH_IPV6_CSUM
> +struct in6_addr;
>  static __inline__ unsigned short int csum_ipv6_magic(struct in6_addr *saddr,
>  						     struct in6_addr *daddr,
>  						     __u32 len,

I use x86_64, which explains why I saw the error:

struct in6_addr;

#define _HAVE_ARCH_IPV6_CSUM 1
csum_ipv6_magic(struct in6_addr *saddr, struct in6_addr *daddr,
                __u32 len, unsigned short proto, unsigned int sum);

Regards
Patrick
