From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Fix inter family IPsec tunnel handling again
Date: Thu, 3 Jul 2008 13:22:03 +0200
Message-ID: <20080703112203.GM9549@secunet.com>
References: <20080703085542.GJ9549@secunet.com> <20080703090522.GB27923@gondor.apana.org.au> <20080703091836.GK9549@secunet.com> <20080703095312.GA28238@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:48529 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758583AbYGCMSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 08:18:18 -0400
Content-Disposition: inline
In-Reply-To: <20080703095312.GA28238@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 05:53:12PM +0800, Herbert Xu wrote:
> On Thu, Jul 03, 2008 at 11:18:36AM +0200, Steffen Klassert wrote:
> >
> > Well, I added the ifdef because it was there in the 2.6.24 code,
> > I could remove it and resend if you agree with the rest of the patch.
> 
> You missed my point.  The fact that you're testing for IPv6 at all
> is the bit that requires explanation.
> 
At one point when I tried to find out why the inter family tunnels
don't work I thought that I can't be sure which header I have to
remove. I double checked this and in fact the test for IPV6 is not
necessary. I will send an updated patch. 


Steffen
