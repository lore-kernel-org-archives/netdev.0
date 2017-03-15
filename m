From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] fjes: Fix wrong netdevice feature flags
Date: Wed, 15 Mar 2017 12:43:56 -0700 (PDT)
Message-ID: <20170315.124356.517921155168414807.davem@davemloft.net>
References: <1489553270-7754-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yasu.isimatu@gmail.com
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751183AbdCOToA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 15:44:00 -0400
In-Reply-To: <1489553270-7754-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Wed, 15 Mar 2017 13:47:50 +0900

> This patch fixes netdev->features for Extended Socket network device.
> 
> Currently Extended Socket network device's netdev->feature claims
> NETIF_F_HW_CSUM, however this is completely wrong. There's no feature
> of checksum offloading.
> That causes invalid TCP/UDP checksum and packet rjection when IP
> forwarding from Extended Socket network device to other network device.
> 
> NETIF_F_HW_CSUM should be omitted.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

Applied, thanks.
