From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: get sock from transport in
 sctp_transport_update_pmtu
Date: Wed, 05 Apr 2017 07:20:18 -0700 (PDT)
Message-ID: <20170405.072018.442632537243215600.davem@davemloft.net>
References: <c3e6d7cac1bc8d426be814c17c87dd9a7d4f3df9.1491284395.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932089AbdDEOU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:20:26 -0400
In-Reply-To: <c3e6d7cac1bc8d426be814c17c87dd9a7d4f3df9.1491284395.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue,  4 Apr 2017 13:39:55 +0800

> This patch is almost to revert commit 02f3d4ce9e81 ("sctp: Adjust PMTU
> updates to accomodate route invalidation."). As t->asoc can't be NULL
> in sctp_transport_update_pmtu, it could get sk from asoc, and no need
> to pass sk into that function.
> 
> It is also to remove some duplicated codes from that function.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
