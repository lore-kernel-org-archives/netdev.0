From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 15:07:03 +0800
Message-ID: <20081016070703.GA5199@gondor.apana.org.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net> <20081016054159.GA4696@gondor.apana.org.au> <20081016054833.GA9030@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Alex Samad <alex@samad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36479 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752300AbYJPHHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 03:07:10 -0400
Content-Disposition: inline
In-Reply-To: <20081016054833.GA9030@samad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2008 at 04:48:33PM +1100, Alex Samad wrote:
>
> > I'm tempted to blame tg3's management of netdev feature setting
> 
> I am using forcedeth not tg3 

Aha, then something is definitely screwed with the feature setting
because forcedeth doesn't even claim support for TSO6 or IPv6
checksum offload.

I wonder if sk_setup_caps is being called before we've set the
GSO type...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
