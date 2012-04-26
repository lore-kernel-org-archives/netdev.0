From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp repair: Fix unaligned access when repairing
 options (v2)
Date: Thu, 26 Apr 2012 06:14:17 -0400 (EDT)
Message-ID: <20120426.061417.1835457785025147124.davem@davemloft.net>
References: <4F9918A8.20100@sacred.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com, xemul@sacred.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab2DZKO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 06:14:27 -0400
In-Reply-To: <4F9918A8.20100@sacred.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@sacred.ru>
Date: Thu, 26 Apr 2012 13:43:04 +0400

> From: Pavel Emelyanov <xemul@parallels.com>
> 
> Don't pick __u8/__u16 values directly from raw pointers, but instead use
> an array of structures of code:value pairs. This is OK, since the buffer
> we take options from is not an skb memory, but a user-to-kernel one.
> 
> For those options which don't require any value now, require this to be
> zero (for potential future extension of this API).
> 
> v2: Changed tcp_repair_opt to use two __u32-s as spotted by David Laight.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Seems to have worked this time, applied :-)
