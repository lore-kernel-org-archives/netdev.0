From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rhashtable: Add arbitrary rehash function
Date: Wed, 11 Mar 2015 16:37:28 -0400 (EDT)
Message-ID: <20150311.163728.900643743533456739.davem@davemloft.net>
References: <20150309222631.GA12221@gondor.apana.org.au>
	<E1YV69U-0003Dq-HS@gondolin.me.apana.org.au>
	<20150310224348.GA29994@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, josh@joshtriplett.org,
	paulmck@linux.vnet.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbCKUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 16:37:31 -0400
In-Reply-To: <20150310224348.GA29994@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 11 Mar 2015 09:43:48 +1100

> This patch adds a rehash function that supports the use of any
> hash function for the new table.  This is needed to support changing
> the random seed value during the lifetime of the hash table.
> 
> However for now the random seed value is still constant and the
> rehash function is simply used to replace the existing expand/shrink
> functions.
> 
> Signed-off-by: Herbert Xu <herbert.xu@redhat.com>

I applied both patches, but for this one I had to tack on
a removal of ASSERT_BUCKET_LOCK(), debug_dump_table(), and
debug_dump_buckets() as they are no longer used.

Please watch the compiler warning output when making changes,
thanks.
