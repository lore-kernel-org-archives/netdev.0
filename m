From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] xfrm: check function pointer of xfrm_mgr
 before use it
Date: Mon, 11 Nov 2013 00:09:39 -0500 (EST)
Message-ID: <20131111.000939.808646582022019973.davem@davemloft.net>
References: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
	<1384126317-3687-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
	netdev@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab3KKFKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:10:12 -0500
In-Reply-To: <1384126317-3687-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: baker.kernel@gmail.com
Date: Mon, 11 Nov 2013 07:31:57 +0800

> From: "baker.zhang" <baker.kernel@gmail.com>
> 
> Signed-off-by: baker.zhang <baker.kernel@gmail.com>

It is not valid to register a key manager that does not implement
these callbacks.

I'm not applying this patch, sorry.  Although I would apply a patch
that validates that all the callbacks are non-NULL at register time.
