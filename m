From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/4] rhashtable: Remove obj_raw_hashfn
Date: Thu, 12 Mar 2015 14:15:24 +0000
Message-ID: <20150312141524.GA5378@casper.infradead.org>
References: <20150312034923.GA14415@gondor.apana.org.au>
 <E1YVu7x-0003mE-G7@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50310 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbbCLOPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:15:25 -0400
Content-Disposition: inline
In-Reply-To: <E1YVu7x-0003mE-G7@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/15 at 02:49pm, Herbert Xu wrote:
> Now that the only caller of obj_raw_hashfn is head_hashfn, we can
> simply kill it and fold it into the latter.
> 
> This patch also moves the common shift from head_hashfn/key_hashfn
> into rht_bucket_index.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
