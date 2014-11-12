From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: Neaten function pointer calls and add
 braces
Date: Wed, 12 Nov 2014 14:52:21 -0500 (EST)
Message-ID: <20141112.145221.1627081153686838525.davem@davemloft.net>
References: <1415771960.16070.21.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter@hurleysoftware.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbaKLTwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 14:52:25 -0500
In-Reply-To: <1415771960.16070.21.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Nov 2014 21:59:20 -0800

> Standardize function pointer uses.
> 
> Convert calling style from:
> 	(*foo)(args...);
> to:
> 	foo(args...);
> 
> Other miscellanea:
> 
> o Add braces around loops with single ifs on multiple lines
> o Realign arguments around these functions
> o Invert logic in if to return immediately.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
