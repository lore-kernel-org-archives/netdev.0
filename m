From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ethernet: nb8800: fix error return code in
 nb8800_open()
Date: Mon, 17 Oct 2016 13:12:25 -0400 (EDT)
Message-ID: <20161017.131225.1321336840505572015.davem@davemloft.net>
References: <1476718318-28428-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, sf84@laposte.net, peter.chen@nxp.com,
        mans@mansr.com, tremyfr@gmail.com, arnd@arndb.de,
        f.fainelli@gmail.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbcJQRM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:12:27 -0400
In-Reply-To: <1476718318-28428-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 17 Oct 2016 15:31:58 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return error code -ENODEV from the of_phy_connect() error
> handling case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
