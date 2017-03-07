From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: fix possible sock_hold() misuses
Date: Tue, 07 Mar 2017 14:06:32 -0800 (PST)
Message-ID: <20170307.140632.293848592181817024.davem@davemloft.net>
References: <20170304050103.12226-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com,
        alexander.h.duyck@intel.com, johannes@sipsolutions.net,
        soheil@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756208AbdCGWPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:15:47 -0500
In-Reply-To: <20170304050103.12226-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri,  3 Mar 2017 21:01:01 -0800

> skb_complete_wifi_ack() and skb_complete_tx_timestamp() currently
> call sock_hold() on sockets that might have transitioned their sk_refcnt
> to zero already.

Series applied and queued up for -stable, thanks.
