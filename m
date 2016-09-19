From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 0/6] sctp: fix the transmit err process
Date: Sun, 18 Sep 2016 22:03:08 -0400 (EDT)
Message-ID: <20160918.220308.1356173755824789782.davem@davemloft.net>
References: <cover.1473789537.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbcISCDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:03:12 -0400
In-Reply-To: <cover.1473789537.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 14 Sep 2016 02:04:17 +0800

> This patchset is to improve the transmit err process and also fix some
> issues.
> 
> After this patchset, once the chunks are enqueued successfully, even
> if the chunks fail to send out, no matter because of nodst or nomem,
> no err retruns back to users any more. Instead, they are taken care
> of by retransmit.
> 
> v1->v2:
>   - add more details to the changelog in patch 1/6
>   - add Fixes: tag in patch 2/6, 3/6
>   - also revert 69b5777f2e57 in patch 3/6

Since SCTP's behavior has been like this for a long time I've applied
this series to net-next, thanks.
