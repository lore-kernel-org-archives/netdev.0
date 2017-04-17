From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: xgene-v2: Extend ethtool
 statistics
Date: Mon, 17 Apr 2017 15:20:53 -0400 (EDT)
Message-ID: <20170417.152053.19747385045166399.davem@davemloft.net>
References: <1492213698-27813-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        patches@apm.com, kchudgar@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757205AbdDQTVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:21:00 -0400
In-Reply-To: <1492213698-27813-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Fri, 14 Apr 2017 16:48:18 -0700

> +	XGE_EXTD_STAT(rx_byte_cntr, RBYT),
> +	XGE_EXTD_STAT(rx_pkt_cntr, RPKT),
> +	XGE_EXTD_STAT(rx_fcs_error_cntr, RFCS),
> +	XGE_EXTD_STAT(rx_multicast_pkt_cntr, RMCA),
> +	XGE_EXTD_STAT(rx_broadcast_pkt_cntr, RBCA),

Do not duplicate statistics already reported via xge_get_stats64().
