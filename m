From: David Miller <davem@davemloft.net>
Subject: Re: SKB Reference Question
Date: Thu, 02 Nov 2017 14:35:57 +0900 (KST)
Message-ID: <20171102.143557.1541082339282323563.davem@davemloft.net>
References: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: codesoldier1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42358 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdKBFgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 01:36:01 -0400
In-Reply-To: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Smith <codesoldier1@gmail.com>
Date: Wed, 1 Nov 2017 10:27:49 -0700

> How strictly are references on the SKB enforced. For example,
> tcp_transmit_skb() clones the SKB and adds a TCP header. Can I assume
> that in case of re-transmission the header added will be there and can
> be reused instead of creating a new one from scratch. Some fields like
> time stamp would need to be updated but they should be unmodified.

Every time a data packet goes out, whether it is the initial transmission
or a retransmission, it goes through tcp_transmit_skb() which pushes the
TCP headers and fills in all of the TCP header options as well.
