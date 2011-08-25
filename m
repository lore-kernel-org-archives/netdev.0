From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 2/2] af-packet: TPACKET_V3 flexible buffer
 implementation.
Date: Wed, 24 Aug 2011 19:43:15 -0700 (PDT)
Message-ID: <20110824.194315.517049778318408046.davem@davemloft.net>
References: <1313785096-911-1-git-send-email-loke.chetan@gmail.com>
	<1313785096-911-3-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab1HYCnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 22:43:21 -0400
In-Reply-To: <1313785096-911-3-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <loke.chetan@gmail.com>
Date: Fri, 19 Aug 2011 16:18:16 -0400

> 1) Blocks can be configured with non-static frame-size.
> 2) Read/poll is at a block-level(as opposed to packet-level).
> 3) Added poll timeout to avoid indefinite user-space wait on idle links.
> 4) Added user-configurable knobs:
>    4.1) block::timeout.
>    4.2) tpkt_hdr::sk_rxhash.
> 
> 
> Changes:
> C1) tpacket_rcv()
>     C1.1) packet_current_frame() is replaced by packet_current_rx_frame()
>           The bulk of the processing is then moved in the following chain:
>           packet_current_rx_frame()
>             __packet_lookup_frame_in_block
>               fill_curr_block()
>               or
>                 retire_current_block
>                 dispatch_next_block
>               or
>               return NULL(queue is plugged/paused)
> 
> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>

Applied.
