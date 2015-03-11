From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] rhashtable: Add arbitrary rehash function
Date: Thu, 12 Mar 2015 08:07:10 +1100
Message-ID: <20150311210710.GB10537@gondor.apana.org.au>
References: <20150309222631.GA12221@gondor.apana.org.au>
 <E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
 <20150310224348.GA29994@gondor.apana.org.au>
 <20150311.163728.900643743533456739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, josh@joshtriplett.org,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35525 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbbCKVHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:07:23 -0400
Content-Disposition: inline
In-Reply-To: <20150311.163728.900643743533456739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 04:37:28PM -0400, David Miller wrote:
>
> I applied both patches, but for this one I had to tack on
> a removal of ASSERT_BUCKET_LOCK(), debug_dump_table(), and
> debug_dump_buckets() as they are no longer used.

Sorry, I didn't have PROVE_LOCKING on so I didn't see these
warnings.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
