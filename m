From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: process fwd tsn chunk only when prsctp
 is enabled
Date: Mon, 06 Feb 2017 11:57:29 -0500 (EST)
Message-ID: <20170206.115729.1722855528495817146.davem@davemloft.net>
References: <16dcae6a3bff4b7e4c6d37bfa7dba217d5ca34b7.1486114626.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750950AbdBFQ5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:57:32 -0500
In-Reply-To: <16dcae6a3bff4b7e4c6d37bfa7dba217d5ca34b7.1486114626.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri,  3 Feb 2017 17:37:06 +0800

> This patch is to check if asoc->peer.prsctp_capable is set before
> processing fwd tsn chunk, if not, it will return an ERROR to the
> peer, just as rfc3758 section 3.3.1 demands.
> 
> Reported-by: Julian Cordes <julian.cordes@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
