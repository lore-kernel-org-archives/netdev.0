From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/1] tipc: accept PACKET_MULTICAST packets
Date: Mon, 14 Aug 2017 11:19:42 -0700 (PDT)
Message-ID: <20170814.111942.369539648096109896.davem@davemloft.net>
References: <1502726156-5536-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38844 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbdHNSTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 14:19:43 -0400
In-Reply-To: <1502726156-5536-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 14 Aug 2017 17:55:56 +0200

> On L2 bearers, the TIPC broadcast function is sending out packets using
> the corresponding L2 broadcast address. At reception, we filter such
> packets under the assumption that they will also be delivered as
> broadcast packets.
> 
> This assumption doesn't always hold true. Under high load, we have seen
> that a switch may convert the destination address and deliver the packet
> as a PACKET_MULTICAST, something leading to inadvertently dropped
> packets and a stale and reset broadcast link.
> 
> We fix this by extending the reception filtering to accept packets of
> type PACKET_MULTICAST.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
