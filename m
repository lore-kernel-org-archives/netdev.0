From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Remove some pointless conditionals before
	kfree_skb()
Date: Tue, 24 Feb 2009 17:55:06 +0800
Message-ID: <20090224095506.GA21985@gondor.apana.org.au>
References: <20090224094738.GA21939@gondor.apana.org.au> <49A3C3D1.2040908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org, davem@davemloft.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47163 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752134AbZBXJzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 04:55:10 -0500
Content-Disposition: inline
In-Reply-To: <49A3C3D1.2040908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 05:54:25PM +0800, Yang Hongyang wrote:
>
> > These checks were specifically added so that callers didn't have
> > to check for NULL.
> 
> Yes,but if the the callers checked for NULL,it's OK right?

Well people will continue to send patches to remove them until
they're all gone :)

Really this isn't even worth discussing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
