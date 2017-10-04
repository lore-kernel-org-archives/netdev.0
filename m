From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ravb: RX checksum offload
Date: Wed, 04 Oct 2017 10:26:34 -0700 (PDT)
Message-ID: <20171004.102634.1443361093432796779.davem@davemloft.net>
References: <1507103667-6084-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: horms+renesas@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdJDR0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:26:36 -0400
In-Reply-To: <1507103667-6084-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms+renesas@verge.net.au>
Date: Wed,  4 Oct 2017 09:54:27 +0200

> Add support for RX checksum offload. This is enabled by default and
> may be disabled and re-enabled using ethtool:
> 
>  # ethtool -K eth0 rx off
>  # ethtool -K eth0 rx on
> 
> The RAVB provides a simple checksumming scheme which appears to be
> completely compatible with CHECKSUM_COMPLETE: sum of all packet data after
> the L2 header is appended to packet data; this may be trivially read by the
> driver and used to update the skb accordingly.
> 
> In terms of performance throughput is close to gigabit line-rate both with
> and without RX checksum offload enabled. Perf output, however, appears to
> indicate that significantly less time is spent in do_csum(). This is as
> expected.
 ...
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Applied, thanks Simon.
