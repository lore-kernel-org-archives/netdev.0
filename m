From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Omit private ndo_get_stats function
Date: Tue, 14 Feb 2017 15:04:16 -0500 (EST)
Message-ID: <20170214.150416.428364556873522801.davem@davemloft.net>
References: <20170214164712.18561-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751934AbdBNUER (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:04:17 -0500
In-Reply-To: <20170214164712.18561-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 14 Feb 2017 17:47:12 +0100

> pch_gbe_get_stats() just returns dev->stats so we can leave it out
> altogether and let dev_get_stats() do the job.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Also applied to net-next, thanks.
