From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: validate source address if the packet is for us
Date: Mon, 17 Feb 2014 00:13:04 -0500 (EST)
Message-ID: <20140217.001304.984853490230460521.davem@davemloft.net>
References: <53019823.20700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaBQFNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:13:06 -0500
In-Reply-To: <53019823.20700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Mon, 17 Feb 2014 13:03:31 +0800

> otherwise the host may deal with the invaild packet.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Locally bound packets are in fact the one case we do not
want source address validation to occur for performance
reasons, it's the whole reason this is coded the way that
it is.

Turn on rpfilter if you have a machine directly exposed
to the internet with no ingress firewalls/routers there
to validate the source address.

I am not applying this patch.
