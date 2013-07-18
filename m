From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/6] bnx2x: properly initialize statistic
 counters
Date: Wed, 17 Jul 2013 18:16:40 -0700 (PDT)
Message-ID: <20130717.181640.758290582728536510.davem@davemloft.net>
References: <1374098440-27877-1-git-send-email-dmitry@broadcom.com>
	<1374098440-27877-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964933Ab3GRBQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 21:16:41 -0400
In-Reply-To: <1374098440-27877-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 18 Jul 2013 01:00:35 +0300

>  {
>  	int /*abs*/port = BP_PORT(bp);
>  	int mb_idx = BP_FW_MB_IDX(bp);
> +	struct stats_counter *counters = &bp->fw_stats_data->storm_counters;

Please order local variable declarations from longest to shortest
line.

Thank you.
