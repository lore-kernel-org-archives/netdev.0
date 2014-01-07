From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH] mlx4_en: Select PTP_1588_CLOCK
Date: Tue, 7 Jan 2014 12:57:23 -0600
Message-ID: <20140107185723.GA6897@sbohrermbp13-local.rgmadvisors.com>
References: <1389120557-6773-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:41635 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbaAGS5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 13:57:33 -0500
Received: by mail-yh0-f44.google.com with SMTP id f64so102383yha.31
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 10:57:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389120557-6773-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 12:49:17PM -0600, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> Now that mlx4_en includes a PHC driver it must select PTP_1588_CLOCK.
> 
>    drivers/built-in.o: In function `mlx4_en_get_ts_info':
> >> en_ethtool.c:(.text+0x391a11): undefined reference to `ptp_clock_index'
>    drivers/built-in.o: In function `mlx4_en_remove_timestamp':
> >> (.text+0x397913): undefined reference to `ptp_clock_unregister'
>    drivers/built-in.o: In function `mlx4_en_init_timestamp':
> >> (.text+0x397b20): undefined reference to `ptp_clock_register'
> 
> Fixes: ad7d4eaed995d ("mlx4_en: Add PTP hardware clock")
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

Sorry forgot to add this is against net-next.

--
Shawn
