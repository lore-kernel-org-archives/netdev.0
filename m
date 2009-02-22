From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] beyond ARRAY_SIZE of ib->btx_ring
Date: Sat, 21 Feb 2009 23:46:56 -0800 (PST)
Message-ID: <20090221.234656.250919495.davem@davemloft.net>
References: <49A0AD1D.1@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58291
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752362AbZBVHrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 02:47:15 -0500
In-Reply-To: <49A0AD1D.1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 22 Feb 2009 02:40:45 +0100

> // vi drivers/net/sunlance.c +216
> struct lance_init_block {
> ...
>         struct lance_tx_desc btx_ring[TX_RING_SIZE];
> ...
> };
> This is a bug, isn't it?

Yep, luckily this is harmless since it just puts a turd
into the TX buffers.

> Do not go beyond ARRAY_SIZE of ib->btx_ring
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks.
