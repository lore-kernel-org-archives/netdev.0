From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: remove temporary variable confirm from
 sctp_packet_transmit
Date: Tue, 21 Mar 2017 18:31:14 -0700 (PDT)
Message-ID: <20170321.183114.2143246486541537142.davem@davemloft.net>
References: <a1bef2ad80e5a7338fc5c6786ea61835014b8c61.1489835542.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, ja@ssi.bg
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdCVBbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:31:18 -0400
In-Reply-To: <a1bef2ad80e5a7338fc5c6786ea61835014b8c61.1489835542.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 18 Mar 2017 19:12:22 +0800

> Commit c86a773c7802 ("sctp: add dst_pending_confirm flag") introduced
> a temporary variable "confirm" in sctp_packet_transmit.
> 
> But it broke the rule that longer lines should be above shorter ones.
> Besides, this variable is not necessary, so this patch is to just
> remove it and use tp->dst_pending_confirm directly.
> 
> Fixes: c86a773c7802 ("sctp: add dst_pending_confirm flag")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
