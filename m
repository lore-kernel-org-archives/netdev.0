From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4.11 -stable] esp4: Fix udpencap for local TCP packets.
Date: Sat, 10 Jun 2017 15:57:37 -0400 (EDT)
Message-ID: <20170610.155737.1892054314418865822.davem@davemloft.net>
References: <20170609093545.GS22049@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdFJT5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 15:57:40 -0400
In-Reply-To: <20170609093545.GS22049@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 9 Jun 2017 11:35:46 +0200

> Locally generated TCP packets are usually cloned, so we
> do skb_cow_data() on this packets. After that we need to
> reload the pointer to the esp header. On udpencap this
> header has an offset to skb_transport_header, so take this
> offset into account.
> 
> This is a backport of:
> commit 0e78a87306a ("esp4: Fix udpencap for local TCP packets.")
> 
> Fixes: 67d349ed603 ("net/esp4: Fix invalid esph pointer crash")
> Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
> Reported-by: Don Bowman <db@donbowman.ca>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Queued up for -stable, thanks Steffen.
