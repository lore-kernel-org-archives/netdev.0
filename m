From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Flow cache flush oops
Date: Thu, 19 Jun 2003 10:07:04 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619000704.GA25135@gondor.apana.org.au>
References: <OFF5CE2037.3D4C9104-ON86256D49.007EAEAD-86256D49.007F5519@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tom Lendacky <toml@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFF5CE2037.3D4C9104-ON86256D49.007EAEAD-86256D49.007F5519@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2003 at 06:10:48PM -0500, Tom Lendacky wrote:
> 
> The compiler version output is:
>   gcc version 3.2 20020903 (Red Hat Linux 8.0 3.2-7)

Thanks, you've found two bugs in my code :) Firstly it's only initialising
one CPU so only that one has a flow cache.  Secondly flow_flush_cache is
not checking whether the calling CPU has been initialised.

I'll post a patch tonight.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
