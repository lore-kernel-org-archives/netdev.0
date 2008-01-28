From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][INET_DIAG]: Fix inet_diag_lock_handler error path
Date: Mon, 28 Jan 2008 22:03:10 +1100
Message-ID: <20080128110310.GA6305@gondor.apana.org.au>
References: <20080128022050.GQ27661@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, spike@ml.yaroslavl.ru,
	netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36630 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751574AbYA1LD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 06:03:28 -0500
Content-Disposition: inline
In-Reply-To: <20080128022050.GQ27661@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 12:20:50AM -0200, Arnaldo Carvalho de Melo wrote:
> Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=9825
> 
> The inet_diag_lock_handler function uses ERR_PTR to encode errors but
> its callers were testing against NULL.

Thanks for catching this Arnaldo!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
