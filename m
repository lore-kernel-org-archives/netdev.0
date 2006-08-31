From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec kernel oops on ppc64
Date: Thu, 31 Aug 2006 11:59:43 +1000
Message-ID: <20060831015942.GA27423@gondor.apana.org.au>
References: <200608301636.k7UGaQY5002569@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@au1.ibm.com, linuxppc-dev@ozlabs.org, paulus@au1.ibm.com,
	davem@davemloft.net, gcwilson@us.ibm.com, jmorris@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49412 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751579AbWHaCAg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 22:00:36 -0400
To: Joy Latten <latten@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <200608301636.k7UGaQY5002569@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 11:36:26AM -0500, Joy Latten wrote:
> 
> I tried the patch on the following:
> linux-2.6.17 + patch-2.6.18-rc1
> 
> The good news is that the pings worked great!
> So perhaps ESP is working ok with ICMP.
> 
> But when I tried to do sftp, I still got the oops.
> I don't think TCP and ESP are working.

Interesting.  We were previously off by 28 bytes, now we're off by 8 :)

Could you please do a test by deleting the defines for
__HAVE_ARCH_MEMMOVE and __HAVE_ARCH_MEMCPY from include/asm-powerpc
to see if using the generic routines help?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
