From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp on
 tpacket_v3 in tx mode
Date: Wed, 4 Jan 2017 21:10:05 -0500
Message-ID: <20170105021005.GI31756@oracle.com>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, willemb@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22856 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758888AbdAECKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 21:10:40 -0500
Content-Disposition: inline
In-Reply-To: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/05/17 02:34), Daniel Borkmann wrote:
> When TX timestamping is in use with TPACKET_V3's TX ring, then we'll
> hit the BUG() in __packet_set_timestamp() when ring buffer slot is
> returned to user space via tpacket_destruct_skb(). This is due to v3
> being assumed as unreachable here, but since 7f953ab2ba46 ("af_packet:
> TX_RING support for TPACKET_V3") it's not anymore. Fix it by filling
> the timestamp back into the ring slot.

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

--Sowmini
