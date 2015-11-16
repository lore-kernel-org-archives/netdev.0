From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunder: Fix crash upon shutdown after failed
 probe
Date: Mon, 16 Nov 2015 09:26:24 -0500 (EST)
Message-ID: <20151116.092624.744220990052005545.davem@davemloft.net>
References: <1447329318-7840-1-git-send-email-p.fedin@samsung.com>
	<20151115.183037.1090427973434503108.davem@davemloft.net>
	<00c301d12071$c4b8be50$4e2a3af0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	youngmin.lee@cavium.com, kin-yip.liu@cavium.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbKPO03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 09:26:29 -0500
In-Reply-To: <00c301d12071$c4b8be50$4e2a3af0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Mon, 16 Nov 2015 16:21:06 +0300

>  Thank you very much, however i've just found one more case where i
> still get this crash. I should have done this from the beginning,
> but please revert it in your repo, i'm sending v2, which covers more
> cases.  The new case is feeding the device to vfio after the probe
> failed. In this case nicvf_remove() is called upon unbind.

Commits installed in my tree are part of the permanent commit
reccord, and will not be reverted.

Please instead send me a relative patch which takes care of
the other cases.

Thanks.
