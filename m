From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Select PTP_1588_CLOCK
Date: Tue, 07 Jan 2014 16:24:03 -0500 (EST)
Message-ID: <20140107.162403.271069132339632530.davem@davemloft.net>
References: <1389120557-6773-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, amirv@mellanox.com,
	richardcochran@gmail.com, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, hadarh@mellanox.com, sbohrer@rgmadvisors.com
To: shawn.bohrer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbaAGVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:24:05 -0500
In-Reply-To: <1389120557-6773-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <shawn.bohrer@gmail.com>
Date: Tue,  7 Jan 2014 12:49:17 -0600

> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> Now that mlx4_en includes a PHC driver it must select PTP_1588_CLOCK.
> 
>    drivers/built-in.o: In function `mlx4_en_get_ts_info':
>>> en_ethtool.c:(.text+0x391a11): undefined reference to `ptp_clock_index'
>    drivers/built-in.o: In function `mlx4_en_remove_timestamp':
>>> (.text+0x397913): undefined reference to `ptp_clock_unregister'
>    drivers/built-in.o: In function `mlx4_en_init_timestamp':
>>> (.text+0x397b20): undefined reference to `ptp_clock_register'
> 
> Fixes: ad7d4eaed995d ("mlx4_en: Add PTP hardware clock")
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

Looks good, applied, thanks.
