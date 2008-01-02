From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Return EOVERFLOW when output sequence number overflows
Date: Tue, 01 Jan 2008 23:53:42 -0800 (PST)
Message-ID: <20080101.235342.183794044.davem@davemloft.net>
References: <20080102071619.GA23687@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59430
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752823AbYABHxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 02:53:42 -0500
In-Reply-To: <20080102071619.GA23687@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 2 Jan 2008 18:16:20 +1100

> [IPSEC]: Return EOVERFLOW when output sequence number overflows
> 
> Previously we made it an error on the output path if the sequence number
> overflowed.  However we did not set the err variable accordingly.  This
> patch sets err to -EOVERFLOW in that case.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

It seems this was a regression added by Paul's patch in net-2.6.25 and
not something that needs fixing in 2.6.24 and stable?
