From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/5 net-next] rhashtable: Disable automatic shrinking by
 default
Date: Wed, 25 Mar 2015 05:55:45 +1100
Message-ID: <20150324185545.GA15837@gondor.apana.org.au>
References: <cover.1427202823.git.tgraf@suug.ch>
 <f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49518 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbbCXSzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 14:55:52 -0400
Content-Disposition: inline
In-Reply-To: <f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 02:18:19PM +0100, Thomas Graf wrote:
> Using rhashtable_remove_fast() will no longer automatically
> shrink the table. Users need to opt-in to shrinking by
> explicitly using rhashtable_remove_and_shrink()
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Note that this patch doesn't completely disable automatic shrinking
since the worker thread can still trigger it.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
