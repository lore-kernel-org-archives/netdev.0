From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH] netdev: Reset ipv4 flags during bundle creation on interfamily ipsec
Date: Fri, 19 Oct 2007 16:20:30 +0300
Message-ID: <200710191620.31168.joakim.koskela@hiit.fi>
References: <200710191437.39449.joakim.koskela@hiit.fi> <200710191440.17232.joakim.koskela@hiit.fi> <20071019130905.GA14032@gondor.apana.org.au>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:36163 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756137AbXJSNZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 09:25:09 -0400
In-Reply-To: <20071019130905.GA14032@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 October 2007 16:09:05 Herbert Xu wrote:
> On Fri, Oct 19, 2007 at 02:40:16PM +0300, Joakim Koskela wrote:
> >
> > This bit was chopped off the larger patch dealing with the problems
> > related to creating the bundles for inter-family tranformations.
>
> This changes behaviour.  Previously the same TOS value would be
> used all the way through.  With this it won't apply to the first
> tunnel and every SA after it.
>
> Cheers,

I'm not sure I follow. This affects the ipv6 bundling only where the struct 
(fl_tunnel) has previously been used for ipv6 addresses. Not that we are 
using the same block for holding the ipv4 info, the tos-value is really 
undefined before we reset it.

br, j
