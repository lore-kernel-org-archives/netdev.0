From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp
 on tpacket_v3 in tx mode
Date: Wed, 04 Jan 2017 23:51:05 -0500 (EST)
Message-ID: <20170104.235105.547654899088862054.davem@davemloft.net>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, willemb@google.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932111AbdAEEvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 23:51:12 -0500
In-Reply-To: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  5 Jan 2017 02:34:28 +0100

> When TX timestamping is in use with TPACKET_V3's TX ring, then we'll
> hit the BUG() in __packet_set_timestamp() when ring buffer slot is
> returned to user space via tpacket_destruct_skb(). This is due to v3
> being assumed as unreachable here, but since 7f953ab2ba46 ("af_packet:
> TX_RING support for TPACKET_V3") it's not anymore. Fix it by filling
> the timestamp back into the ring slot.
> 
> Fixes: 7f953ab2ba46 ("af_packet: TX_RING support for TPACKET_V3")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
