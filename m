From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: replace netdev_alloc_skb_ip_align with
 napi_alloc_skb
Date: Thu, 09 Jun 2016 23:38:34 -0700 (PDT)
Message-ID: <20160609.233834.1165575341006793639.davem@davemloft.net>
References: <1394712342-15778-174-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbcFJGif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 02:38:35 -0400
In-Reply-To: <1394712342-15778-174-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 8 Jun 2016 14:52:33 +0800

> Replace netdev_alloc_skb_ip_align() with napi_alloc_skb() which can save
> several CPU cycles by avoiding having to disable and re-enable IRQs.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
