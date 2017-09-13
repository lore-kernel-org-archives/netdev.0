From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: fix TSO6/GSO issue causing TX-stall on
 Lancer/BEx
Date: Wed, 13 Sep 2017 09:33:00 -0700 (PDT)
Message-ID: <20170913.093300.354502012122342306.davem@davemloft.net>
References: <Suresh.Reddy@broadcom.com>
        <20170913151242.16303-1-suresh.reddy@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: suresh.reddy@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751639AbdIMQdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 12:33:01 -0400
In-Reply-To: <20170913151242.16303-1-suresh.reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@broadcom.com>
Date: Wed, 13 Sep 2017 11:12:42 -0400

> IPv6 TSO requests with extension hdrs are a problem to the
> Lancer and BEx chips. Workaround is to disable TSO6 feature
> for such packets.
> 
> Also in Lancer chips, MSS less than 256 was resulting in TX stall.
> Fix this by disabling GSO when MSS less than 256.
> 
> Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>

Applied.
