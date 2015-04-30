From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 2/2] rhashtable: Quick initial growth of tables
Date: Fri, 1 May 2015 07:45:56 +0800
Message-ID: <20150430234556.GA31180@gondor.apana.org.au>
References: <1430434005-6143-3-git-send-email-tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48612 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbD3XqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 19:46:02 -0400
Content-Disposition: inline
In-Reply-To: <1430434005-6143-3-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> wrote:
> Grow the table quicker than 2x in the beginning to avoid long chains
> of rehashes. The effect is observable in the self-test where table
> jumps are reduced to a minimum after a lot of entries have been added
> in a short period of time. The iterator is able to get a consistent
> view most of the time.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Wouldn't automatic shrinking immediately undo your quick growth?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
