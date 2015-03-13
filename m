From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/6] rhashtable: Fixes + cleanups + preparation for
 multiple rehash
Date: Fri, 13 Mar 2015 13:57:14 +0000
Message-ID: <20150313135714.GC17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56909 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbbCMN5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:57:15 -0400
Content-Disposition: inline
In-Reply-To: <20150313095607.GA598@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:56pm, Herbert Xu wrote:
> Hi:
> 
> Patch 1 fixes the walker so that it behaves properly even during
> a resize.
> 
> Patch 2-3 are cleanups.
> 
> Patch 4-6 lays some ground work for the upcoming multiple rehashing.

Tested this series plus already committed rehash fix with netlink
and nft tests. All works well.

Tested-by: Thomas Graf <tgraf@suug.ch>
