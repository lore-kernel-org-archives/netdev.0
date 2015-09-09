From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: Fix the initial device operstate
Date: Wed, 09 Sep 2015 12:10:33 -0700 (PDT)
Message-ID: <20150909.121033.958381315580450183.davem@davemloft.net>
References: <20150908.181541.478844573.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org
To: nemoto@toshiba-tops.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbIITKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:10:35 -0400
In-Reply-To: <20150908.181541.478844573.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Date: Tue, 8 Sep 2015 18:15:41 +0900

> Call netif_carrier_off() prior to register_netdev(), otherwise
> userspace can see incorrect link state.
> 
> Signed-off-by: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>

Applied.
