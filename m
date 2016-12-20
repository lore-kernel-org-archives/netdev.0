From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Increase skb headroom size to 256 bytes
Date: Tue, 20 Dec 2016 14:30:32 -0500 (EST)
Message-ID: <20161220.143032.511618714729371345.davem@davemloft.net>
References: <20161220151430.11115-1-suresh.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kalesh-anakkur.purayil@broadcom.com
To: suresh.reddy@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934320AbcLTTak (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 14:30:40 -0500
In-Reply-To: <20161220151430.11115-1-suresh.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>
Date: Tue, 20 Dec 2016 10:14:30 -0500

> From: Kalesh A P <kalesh-anakkur.purayil@broadcom.com>
> 
> The driver currently allocates 128 bytes of skb headroom.
> This was found to be insufficient with some configurations
> like Geneve tunnels, which resulted in skb head reallocations.
> 
> Increase the headroom to 256 bytes to fix this.
> 
> Signed-off-by: Kalesh A P <kalesh-anakkur.purayil@broadcom.com>
> Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>

Adding 128 bytes of headroom just for geneve seems excessive.

Do you really need to add that much?
