From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dm9000: Return an ERR_PTR() in all error
 conditions of dm9000_parse_dt()
Date: Mon, 22 Sep 2014 16:03:13 -0400 (EDT)
Message-ID: <20140922.160313.17177368094902322.davem@davemloft.net>
References: <1411136185-28658-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaIVUDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:03:16 -0400
In-Reply-To: <1411136185-28658-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 19 Sep 2014 16:16:25 +0200

> In one error condition dm9000_parse_dt() returns NULL, however the
> return value is checked using IS_ERR() in dm9000_probe(), leading to the
> error not being properly propagated if CONFIG_OF is not enabled or the
> device tree data is not available. Fix this by also returning an
> ERR_PTR() in this case.
> 
> Fixes: 0b8bf1baabe5 (net: dm9000: Allow instantiation using device tree)
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
