From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: macb: fix missing unlock on error in
 macb_start_xmit()
Date: Tue, 13 Sep 2016 11:42:54 -0400 (EDT)
Message-ID: <20160913.114254.1565753177993853606.davem@davemloft.net>
References: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, helmut.buchsbaum@gmail.com,
        weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759196AbcIMPmz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:42:55 -0400
In-Reply-To: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 10 Sep 2016 11:17:57 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix missing unlock before return from function macb_start_xmit()
> in the error handling case.
> 
> Fixes: 007e4ba3ee13 ("net: macb: initialize checksum when using
> checksum offloading")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
