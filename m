From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: clean up sctp_packet_transmit
Date: Tue, 01 Nov 2016 11:58:24 -0400 (EDT)
Message-ID: <20161101.115824.971209598343837049.davem@davemloft.net>
References: <407056b761e77ecbd43603a17099bb9309a9a8ac.1477932581.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752031AbcKAP60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:58:26 -0400
In-Reply-To: <407056b761e77ecbd43603a17099bb9309a9a8ac.1477932581.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  1 Nov 2016 00:49:41 +0800

> After adding sctp gso, sctp_packet_transmit is a quite big function now.
> 
> This patch is to extract the codes for packing packet to sctp_packet_pack
> from sctp_packet_transmit, and add some comments, simplify the err path by
> freeing auth chunk when freeing packet chunk_list in out path and freeing
> head skb early if it fails to pack packet.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

SCTP experts, please review.
