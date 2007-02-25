From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Sat, 24 Feb 2007 16:54:53 -0800 (PST)
Message-ID: <20070224.165453.104035690.davem@davemloft.net>
References: <200702130236.l1D2a0u7014457@clem.clem-digital.net>
	<20070213.115510.21486123.yoshfuji@linux-ipv6.org>
	<20070224225021.GT12392@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, clem@clem.clem-digital.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932425AbXBYAyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 19:54:54 -0500
In-Reply-To: <20070224225021.GT12392@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 24 Feb 2007 23:50:21 +0100

> In the CONFIG_IPV6=m, CONFIG_SUNRPC=m case, this will result in no IPV6 
> support here.
> 
> If you are going this way, a Kconfig helper variable might be better:
> 
> config SUNRPC_IPV6
> 	bool
> 	default y if (SUNRPC=y && IPV6=y) || (SUNRPC=m && IPV6) 

Please, don't worry about any of this, Yoshifuji already
gave me a fix for this, that will provide the symbol statically
and exported to modules, even if  ipv6 is built modular.

So we don't need to worry about this problem any more.
