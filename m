From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Disable addrconf on ~multicast interfaces?
Date: Thu, 5 Oct 2006 16:17:24 +1000
Message-ID: <20061005061724.GA19785@gondor.apana.org.au>
References: <20061005053531.GA19482@gondor.apana.org.au> <20061005.150634.27869684.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11027 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751498AbWJEGR0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 02:17:26 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20061005.150634.27869684.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 03:06:34PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Why do you want to do this?  Xen issue?

Yes it's to disable addrconf on the Xen bridge interface.

> As Alexey mentioned before, addrconf should work even for !MULTICAST &&
> BROADCAST.  This is true for POINTOPOINT as well; ISATAP will use this.

I'm only proposing this as a stop-gap measure until we have a way to
disable addrconf before ifup, or until Xen loses the netloop interface.

So what I'd like to know is what setups this patch would break.  ISATAP
uses SIT right? This patch only affects Ethernet-type interfaces so it
shouldn't affect SIT at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
