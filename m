From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: Driver and hardware supports IPv6 offload, so
 enable it
Date: Fri, 01 Sep 2017 10:36:49 -0700 (PDT)
Message-ID: <20170901.103649.2092905433442183269.davem@davemloft.net>
References: <20170901144949.13129-1-andrewpilloud@igneoussystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org
To: andrewpilloud@igneoussystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752227AbdIARgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:36:50 -0400
In-Reply-To: <20170901144949.13129-1-andrewpilloud@igneoussystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Pilloud <andrewpilloud@igneoussystems.com>
Date: Fri,  1 Sep 2017 07:49:49 -0700

> The mvneta driver and hardware supports IPv6 offload, however it
> isn't enabled. Set the NETIF_F_IPV6_CSUM feature to inform the
> network layer that this driver can offload IPV6 TCP and UDP
> checksums. This change has been tested on an Armada 370 and the
> feature support confirmed with several device datasheets
> including the Armada XP and Armada 3700.
> 
> Signed-off-by: Andrew Pilloud <andrewpilloud@igneoussystems.com>

Applied to net-next, thanks.
