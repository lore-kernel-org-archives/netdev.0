From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [NET] napi: Call __netif_rx_complete in netif_rx_complete
Date: Wed, 23 May 2007 19:50:07 +0200
Message-ID: <200705231950.08210.netdev@axxeo.de>
References: <20070520103910.GA25808@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:51853 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763086AbXEWRuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 13:50:23 -0400
In-Reply-To: <20070520103910.GA25808@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu schrieb:
> [NET] napi: Call __netif_rx_complete in netif_rx_complete
> 
> This patch kills a little bit of code duplication between the two
> variants of netif_rx_complete.

What about making it out of line? 

There is nothing the compiler can optimize away here 
and the code looks bigger than a function call with a single argument.

Maybe even make the callers out of line?


Best regards

Ingo Oeser
