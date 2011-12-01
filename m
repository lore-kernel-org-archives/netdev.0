From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: net_device flags is an unsigned int
Date: Wed, 30 Nov 2011 23:39:18 -0500 (EST)
Message-ID: <20111130.233918.564313369312715101.davem@davemloft.net>
References: <1322714077.2577.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296Ab1LAEjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:39:20 -0500
In-Reply-To: <1322714077.2577.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2011 05:34:37 +0100

> -	unsigned short old_flags = dev->flags;
> +	typeof(dev->flags) old_flags = dev->flags;

Please, create netdev_flags_t or similar, anything but this :-)
