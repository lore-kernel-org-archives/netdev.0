From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Move hash_rnd into bucket_table
Date: Sat, 31 Jan 2015 11:17:51 +0000
Message-ID: <20150131111751.GB22448@casper.infradead.org>
References: <20150131102150.GA29498@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41622 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbbAaLRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 06:17:52 -0500
Content-Disposition: inline
In-Reply-To: <20150131102150.GA29498@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/15 at 09:21pm, Herbert Xu wrote:
> Currently hash_rnd is a parameter that users can set.  However,
> no existing users set this parameter.  It is also something that
> people are unlikely to want to set directly since it's just a
> random number.
>     
> In preparation for allowing the reseeding/rehashing of rhashtable,
> this patch moves hash_rnd into bucket_table so that it's now an
> internal state rather than a parameter.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

For net-next

Acked-by: Thomas Graf <tgraf@suug.ch>
