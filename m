From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: emac: use platform_{get,set}_drvdata()
Date: Tue, 03 Sep 2013 22:40:03 -0400 (EDT)
Message-ID: <20130903.224003.792091851244921220.davem@davemloft.net>
References: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761703Ab3IDCkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:40:07 -0400
In-Reply-To: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 02 Sep 2013 17:06:52 +0900

> Use the wrapper functions for getting and setting the driver data
> using platform_device instead of using dev_{get,set}_drvdata()
> with &pdev->dev, so we can directly pass a struct platform_device.
> This is a purely cosmetic change.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

All 5 patches applied.

Please, in the future, provide an initial "[PATCH 00/nn] " posting for
a series of patches, giving a top-level description of what is happening.

This way I can include that commit message text in a merge commit and
also I have an appropriate email to reply to if I just want to say
that I applied everything in the series.
