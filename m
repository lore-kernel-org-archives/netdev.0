From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: reuse sent_count to avoid retransmitted
 chunks for RTT measurements
Date: Thu, 13 Oct 2016 09:44:50 -0400 (EDT)
Message-ID: <20161013.094450.2198759604771922325.davem@davemloft.net>
References: <b68194a4735a1ea5a652c13540df5d68e3c4b305.1475897765.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60766 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbcJMNrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 09:47:07 -0400
In-Reply-To: <b68194a4735a1ea5a652c13540df5d68e3c4b305.1475897765.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  8 Oct 2016 11:36:05 +0800

> Now sctp uses chunk->resent to record if a chunk is retransmitted, for
> RTT measurements with retransmitted DATA chunks. chunk->sent_count was
> introduced to record how many times one chunk has been sent for prsctp
> RTX policy before. We actually can know if one chunk is retransmitted
> by checking chunk->sent_count is greater than 1.
> 
> This patch is to remove resent from sctp_chunk and reuse sent_count
> to avoid retransmitted chunks for RTT measurements.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
