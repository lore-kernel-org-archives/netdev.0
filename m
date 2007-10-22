From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH] netdev: Interfamily support for IPSEC BEET
Date: Mon, 22 Oct 2007 09:59:02 +0300
Message-ID: <200710220959.02544.joakim.koskela@hiit.fi>
References: <E1Iisk2-0003qj-00@gondolin.me.apana.org.au>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:47903 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752302AbXJVHEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 03:04:13 -0400
In-Reply-To: <E1Iisk2-0003qj-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 October 2007 17:22:22 Herbert Xu wrote:
>
> Please hold onto this.  I've got a more generic version of this
> that doesn't duplicate the inter-family logic between BEET mode
> and tunnel mode.
>
> Instead I've created a generic function that reads info from the
> inner header and puts them in an address-neutral format which is
> then picked up by either BEET or tunnel mode.

Ok, this really sounds like a good development. Do you think it could make it 
in time for 2.6.24?

Thanks,
Joakim
