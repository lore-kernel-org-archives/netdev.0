From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix under-accounting retransmit SNMP counters
Date: Thu, 22 Sep 2016 03:33:26 -0400 (EDT)
Message-ID: <20160922.033326.1817667802370775778.davem@davemloft.net>
References: <1474499775-26436-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbcIVHd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 03:33:29 -0400
In-Reply-To: <1474499775-26436-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 21 Sep 2016 16:16:14 -0700

> This patch fixes these under-accounting SNMP rtx stats
> LINUX_MIB_TCPFORWARDRETRANS
> LINUX_MIB_TCPFASTRETRANS
> LINUX_MIB_TCPSLOWSTARTRETRANS
> when retransmitting TSO packets
> 
> Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
