From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: qcom/emac: move phy init code to separate
 files
Date: Thu, 24 Nov 2016 11:32:20 -0500 (EST)
Message-ID: <20161124.113220.1130207009395086230.davem@davemloft.net>
References: <1479769102-27909-1-git-send-email-timur@codeaurora.org>
        <1479769102-27909-2-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alokc@codeaurora.org, netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756461AbcKXQcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 11:32:22 -0500
In-Reply-To: <1479769102-27909-2-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Mon, 21 Nov 2016 16:58:21 -0600

> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
> new file mode 100644
> index 0000000..46f01b3
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii-fsm9900.c
> @@ -0,0 +1,246 @@
 ...
> +	return 0;
> +}
> +

Please do not place empty blank lines at the end of files.

GIT even warns about this.
