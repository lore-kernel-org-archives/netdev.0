From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Tue, 2 Nov 2004 09:03:34 +1100
Message-ID: <20041101220334.GA23809@gondor.apana.org.au>
References: <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com> <20041101202754.GA23149@gondor.apana.org.au> <20041101203821.GA15086@lists.us.dell.com> <20041101204131.GA23277@gondor.apana.org.au> <20041101204533.GA17279@lists.us.dell.com> <1099345849.1073.1.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099345849.1073.1.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 04:50:49PM -0500, jamal wrote:
> My onluy comment is on use of -EOVERFLOW which i have seen only
> being used in the context of floating point computation
> (same as -EUNDERFLOW). I dont know what the right thing to return would
> be.

How about ERANGE? getcwd(3) uses it.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
