From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Default UDP and UNIX diag to 'n'.
Date: Tue, 07 Feb 2012 12:29:31 -0500 (EST)
Message-ID: <20120207.122931.1509587729423704935.davem@davemloft.net>
References: <20120107.121339.633839797125273714.davem@davemloft.net>
	<20120207121256.50667809@destiny.ordissimo>
	<4F31292F.2090503@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anisse@astier.eu, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513Ab2BGR3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:29:36 -0500
In-Reply-To: <4F31292F.2090503@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 07 Feb 2012 17:37:51 +0400

> @@ -409,7 +409,7 @@ config INET_TCP_DIAG
>  
>  config INET_UDP_DIAG
>  	tristate "UDP: socket monitoring interface"
> -	depends on INET_DIAG
> +	depends on INET_DIAG && IPV6

This needs to be something like "INET_DIAG && (IPV6 || IPV6=n)"
