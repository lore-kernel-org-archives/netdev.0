From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Prevent warning without CONFIG_RFS_ACCEL
Date: Sun, 30 Apr 2017 23:01:03 -0400 (EDT)
Message-ID: <20170430.230103.53209164967311276.davem@davemloft.net>
References: <1493543684-7038-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sudarsana.Kalluru@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750731AbdEADBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 23:01:05 -0400
In-Reply-To: <1493543684-7038-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 30 Apr 2017 12:14:44 +0300

> After removing the PTP related initialization from slowpath start,
> the remaining PTT entry is required only in case CONFIG_RFS_ACCEL is set.
> Otherwise, it leads to a warning due to it being unused.
> 
> Fixes: d179bd1699fc ("qed: Acquire/release ptt_ptp lock when enabling/disabling PTP")
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Also applied, thanks.
