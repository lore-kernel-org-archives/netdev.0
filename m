From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at86rf230: Constify struct regmap_config
Date: Mon, 05 Jan 2015 16:33:11 -0500 (EST)
Message-ID: <20150105.163311.1868277821228057884.davem@davemloft.net>
References: <1420448551-9443-1-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.aring@gmail.com, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbbAEVdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:33:14 -0500
In-Reply-To: <1420448551-9443-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Mon, 05 Jan 2015 10:02:31 +0100

> The regmap_config struct may be const because it is not modified by the
> driver and regmap_init() accepts pointer to const.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Applied.
