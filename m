From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH] netdev: Netfilters on outgoing interfamily ipsec
Date: Fri, 19 Oct 2007 16:18:56 +0300
Message-ID: <200710191618.56476.joakim.koskela@hiit.fi>
References: <200710191437.39449.joakim.koskela@hiit.fi> <20071019125555.GA13955@gondor.apana.org.au>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:53303 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757055AbXJSNXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 09:23:33 -0400
In-Reply-To: <20071019125555.GA13955@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 October 2007 15:55:55 Herbert Xu wrote:
> While I agree that this is definitely a problem, I've already
> got a solution for it which we happen to need for async crypto
> anyway.
>
> Basically xfrm_output will invoke a continuation function based
> on the external mode/family which will then call the right hooks.
>
> Cheers,

Ok, great. Lets go with that.
