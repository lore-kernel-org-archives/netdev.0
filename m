From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rhashtable: Always allocate at least one bucket lock
Date: Wed, 16 Dec 2015 13:53:10 +0800
Message-ID: <20151216055310.GA23634@gondor.apana.org.au>
References: <56709827.1010407@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch, william.hua@canonical.com
To: William Hua <william.hua@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46539 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbbLPFxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 00:53:16 -0500
Content-Disposition: inline
In-Reply-To: <56709827.1010407@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Hua <william.hua@canonical.com> wrote:
> No bucket locks are allocated when an rhashtable is initialized with
> fewer than two elements. In this special case, we should allocate at
> least one to prevent a segfault.
> 
> Signed-off-by: William Hua <william.hua@canonical.com>

Huh? The minimum hash table size is 4.  How are you getting an
rhashtable that's smaller than the required minimum?
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
