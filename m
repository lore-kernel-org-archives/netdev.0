From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.12-rcx networking oops
Date: Wed, 1 Jun 2005 15:49:55 +1000
Message-ID: <20050601054955.GA2625@gondor.apana.org.au>
References: <20050531224012.GA16789@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20050531224012.GA16789@linuxace.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 03:40:12PM -0700, Phil Oester wrote:
>
> EIP is at fib_validate_source+0xcf/0x1f0
> eax: f7c2c000   ebx: c0337dec   ecx: f7c258a0   edx: 00000000
> esi: c0335c2c   edi: 00000000   ebp: c0337db0   esp: c0337d40
> ds: 3f1f   es: 007b   ss: 0068
> Process swapper (pid: 0, threadinfo=c0337000 task=c02b9bc0)

This looks like stack overflow.  %esi is meant to be "res" which is
a local variable.  As you can see, it's pointing below %esp and
threadinfo.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
