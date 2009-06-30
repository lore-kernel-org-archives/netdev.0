From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
	configurable
Date: Wed, 1 Jul 2009 01:00:27 +0800
Message-ID: <20090630170027.GA22691@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47142 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752223AbZF3RA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 13:00:26 -0400
Content-Disposition: inline
In-Reply-To: <1246379267.3749.42.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 05:27:47PM +0100, Mark McLoughlin wrote:
> 
> However, because nf_conntrack introduces an skb_orphan(), it is now
> recommended that bridge-nf-call-iptables be disabled completely so as
> to ensure features like TUNSETSNDBUF work as expected.

Patrick, does conntrack ever make sense for bridging? Perhaps
we should get rid of that completely?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
