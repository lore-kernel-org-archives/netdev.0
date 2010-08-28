From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlx4: use bitmap library
Date: Sat, 28 Aug 2010 15:37:27 -0700 (PDT)
Message-ID: <20100828.153727.115919618.davem@davemloft.net>
References: <1282972093-9885-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolandd@cisco.com
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183Ab0H1WhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:37:11 -0400
In-Reply-To: <1282972093-9885-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 28 Aug 2010 14:08:13 +0900

> Replace loops calling set_bit() and clear_bit() with bitmap_set() and
> bitmap_clear().
> 
> Unlike loops calling set_bit() and clear_bit(), bitmap_set() and
> bitmap_clear() are not atomic. But this is ok.
> Because the bitmap operations are protected by bitmap->lock
> except for initialization of the bitmap in mlx4_bitmap_init().
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Roland Dreier <rolandd@cisco.com>
> Cc: netdev@vger.kernel.org
> Cc: "David S. Miller" <davem@davemloft.net>

Applied.
