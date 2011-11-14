From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESUBMIT3 net-next 2/2] IPv6 routing, NLM_F_* flag
 support: REPLACE and EXCL flags support, warn about missing CREATE flag
Date: Mon, 14 Nov 2011 14:36:10 -0500 (EST)
Message-ID: <20111114.143610.1462209997757759911.davem@davemloft.net>
References: <1321265714.1858.28.camel@hakki>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matti.vaittinen@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1KNTgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:36:16 -0500
In-Reply-To: <1321265714.1858.28.camel@hakki>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Vaittinen <matti.vaittinen@nsn.com>
Date: Mon, 14 Nov 2011 12:15:14 +0200

> 
> The support for NLM_F_* flags at IPv6 routing requests.
> 
> If NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
> warning is printed, but no error is returned. Instead new route is
> added. Later NLM_F_CREATE may be required for
> new route creation.
> 
> Exception is when NLM_F_REPLACE flag is given without NLM_F_CREATE, and
> no matching route is found. In this case it should be safe to assume
> that the request issuer is familiar with NLM_F_* flags, and does really
> not want route to be created.
> 
> Specifying NLM_F_REPLACE flag will now make the kernel to search for
> matching route, and replace it with new one. If no route is found and
> NLM_F_CREATE is specified as well, then new route is created.
> 
> Also, specifying NLM_F_EXCL will yield returning of error if matching
> route is found.
> 
> Patch created against linux-3.2-rc1
>
> Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>

Applied.
