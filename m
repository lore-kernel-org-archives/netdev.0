From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Avoid multi-page allocs for large mtu datagram sends
Date: Thu, 13 Apr 2006 02:20:35 +1000
Message-ID: <20060412162035.GA18572@gondor.apana.org.au>
References: <20060405175102.GA28166@tetsuo.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15883 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932091AbWDLQUj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 12:20:39 -0400
To: Zach Brown <zach.brown@oracle.com>
Content-Disposition: inline
In-Reply-To: <20060405175102.GA28166@tetsuo.zabbo.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 05, 2006 at 05:51:02PM +0000, Zach Brown wrote:
> 
> 2) I changed the final-frag test to be length + fraggap as the math later on
>    seemed to match that.. is that OK?

Yes that's a real bug introduced by a previous rework.  Could you
please split that off into a separate patch?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
