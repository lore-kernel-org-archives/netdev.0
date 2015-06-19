From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2] bridge: multicast: start querier timer when
 running user-space stp
Date: Fri, 19 Jun 2015 21:47:34 +0800
Message-ID: <20150619134734.GA14548@gondor.apana.org.au>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, sashok@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57565 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbbFSNrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 09:47:39 -0400
Content-Disposition: inline
In-Reply-To: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2015 at 01:45:50AM -0700, Nikolay Aleksandrov wrote:
> When STP is running in user-space and querier is configured, the
> querier timer is not started when a port goes to a non-blocking state.
> This patch unifies the user- and kernel-space stp multicast port enable
> path and enables it in all states different from blocking. Note that when a
> port goes in BR_STATE_DISABLED it's not enabled because that is handled
> in the beginning of the port list loop.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

On a related note, we never disable the multicast querying when
the port goes into blocking mode and we probably should.  So could
you take a look at that and create a patch for it?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
