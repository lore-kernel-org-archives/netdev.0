From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/4] rhashtable: Allow local locks to be used and tested
Date: Thu, 13 Nov 2014 10:41:37 +0000
Message-ID: <20141113104137.GB24379@casper.infradead.org>
References: <20141113101025.GA3728@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50704 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932364AbaKMKli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:41:38 -0500
Content-Disposition: inline
In-Reply-To: <20141113101025.GA3728@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/14 at 06:10pm, Herbert Xu wrote:
> Hi:
> 
> This series moves mutex_is_held entirely under PROVE_LOCKING so
> there is zero foot print when we're not debugging.  More importantly
> it adds a parrent argument to mutex_is_held so that we can test
> local locks rather than global ones (e.g., per-namespace locks).

LGTM

Acked-by: Thomas Graf <tgraf@suug.ch>
