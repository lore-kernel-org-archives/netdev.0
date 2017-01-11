From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix the sw rx checksum is unavailable
Date: Wed, 11 Jan 2017 16:09:16 -0500 (EST)
Message-ID: <20170111.160916.187393669546544068.davem@davemloft.net>
References: <1394712342-15778-232-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754056AbdAKVJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:09:21 -0500
In-Reply-To: <1394712342-15778-232-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 11 Jan 2017 16:25:34 +0800

> Fix the hw rx checksum is always enabled, and the user couldn't switch
> it to sw rx checksum.
> 
> Note that the RTL_VER_01 only support sw rx checksum only. Besides,
> the hw rx checksum for RTL_VER_02 is disabled after
> commit b9a321b48af4 ("r8152: Fix broken RX checksums."). Re-enable it.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied and queued up for -stable, thanks.
