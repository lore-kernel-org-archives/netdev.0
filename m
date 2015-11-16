From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunder: Check for driver data in nicvf_remove()
Date: Mon, 16 Nov 2015 16:25:17 -0500 (EST)
Message-ID: <20151116.162517.200378372662377994.davem@davemloft.net>
References: <1447685494-9836-1-git-send-email-p.fedin@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	youngmin.lee@cavium.com, kin-yip.liu@cavium.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbKPVZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 16:25:20 -0500
In-Reply-To: <1447685494-9836-1-git-send-email-p.fedin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Mon, 16 Nov 2015 17:51:34 +0300

> In some cases the crash is caused by nicvf_remove() being called from
> outside. For example, if we try to feed the device to vfio after the
> probe has failed for some reason. So, move the check to better place.
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Applied, thanks.
