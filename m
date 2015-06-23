From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] bridge: multicast: add a comment to
 br_port_state_selection about blocking state
Date: Tue, 23 Jun 2015 21:26:38 +0800
Message-ID: <20150623132638.GA20498@gondor.apana.org.au>
References: <77FF1B4A-1D3A-4F59-A7C7-0ADBB34F8920@cumulusnetworks.com>
 <1435060064-32761-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
	davem@davemloft.net, stephen@networkplumber.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34791 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbbFWN0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:26:44 -0400
Content-Disposition: inline
In-Reply-To: <1435060064-32761-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2015 at 04:47:44AM -0700, Nikolay Aleksandrov wrote:
> Add a comment to explain why we're not disabling port's multicast when it
> goes in blocking state. Since there's a check in the timer's function which
> bypasses the timer if the port's in blocking/disabled state, the timer will
> simply expire and stop without sending more queries.
> 
> Suggested-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
