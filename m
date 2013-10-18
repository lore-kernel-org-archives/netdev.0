From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Removal of struct esp_data
Date: Fri, 18 Oct 2013 13:55:36 -0400 (EDT)
Message-ID: <20131018.135536.686066381481925652.davem@davemloft.net>
References: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au
To: mathias.krause@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756515Ab3JRRzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:55:39 -0400
In-Reply-To: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <mathias.krause@secunet.com>
Date: Fri, 18 Oct 2013 12:09:03 +0200

> This series removes one level of indirection when accessing the aead
> crypto algorithm in ESP transforms by simply removing struct esp_data.
> This results in smaller code and less memory usage per xfrm state.
> 
> Please apply!

No objections from me, I'll let Steffen pick this up.
