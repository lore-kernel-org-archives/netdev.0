From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: jumbo frames and memory fragmentation
Date: Fri, 30 Jun 2006 23:01:42 +1000
Message-ID: <E1FwIcw-00068x-00@gondolin.me.apana.org.au>
References: <44A421D7.2030609@nortel.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:15876 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S932068AbWF3NCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 09:02:31 -0400
To: cfriesen@nortel.com (Chris Friesen)
In-Reply-To: <44A421D7.2030609@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen <cfriesen@nortel.com> wrote:
> 
> Anyone have any suggestions on how to improve this?  Upgrading kernels 
> isn't an option.  I could port back the copybreak stuff fairly easily.

Either upgrade your kernel or backport the page-splitting code in the
current tree.  That's really the only sane solution for jumbo packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
