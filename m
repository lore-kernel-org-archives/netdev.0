From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/4] rhashtable: Move masking back into key_hashfn
Date: Thu, 12 Mar 2015 14:02:33 +0000
Message-ID: <20150312140233.GA4001@casper.infradead.org>
References: <20150312034923.GA14415@gondor.apana.org.au>
 <E1YVu7u-0003lJ-1J@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50245 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193AbbCLOCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:02:34 -0400
Content-Disposition: inline
In-Reply-To: <E1YVu7u-0003lJ-1J@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/15 at 02:49pm, Herbert Xu wrote:
> This patch reverts commit c88455ce50ae4224d84960ce2baa53e61580df27
> ("rhashtable: key_hashfn() must return full hash value") because
> the only user of it always masks the hash value.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Need for this is gone with new rehashing.

Acked-by: Thomas Graf <tgraf@suug.ch>
