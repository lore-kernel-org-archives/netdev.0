From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] fjes: Implement debug mode for fjes driver
Date: Thu, 13 Oct 2016 10:19:30 -0400 (EDT)
Message-ID: <20161013.101930.1034896203915503108.davem@davemloft.net>
References: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
        <1476176120-18859-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932331AbcJMO2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:28:47 -0400
In-Reply-To: <1476176120-18859-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Tue, 11 Oct 2016 17:55:20 +0900

> This patch implements debug mode for fjes driver.
> You can get firmware activity information by enabling
> debug mode. This is useful for debugging.
> 
> To enable debug mode, write value of debugging mode to
> debug_mode file in debugfs:
> 
>   # echo 1 > /sys/kernel/debug/fjes/fjes.0/debug_mode
> 
> To disable debug mode, write 0 to debug_mode file in debugfs:
> 
>   # echo 0 > /sys/kernel/debug/fjes/fjes.0/debug_mode
> 
> Firmware activity information can be retrieved via
> /sys/kernel/debug/fjes/fjes.0/debug_data file.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

There is no reason to use debugfs for this, we have facilities such
as ETHTOOL_SET_DUMP et al. that you can use to implement this.
