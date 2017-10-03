From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] bonding: speed/duplex update at NETDEV_UP event
Date: Tue, 03 Oct 2017 14:32:43 -0700 (PDT)
Message-ID: <20171003.143243.476075670637129212.davem@davemloft.net>
References: <20170928010349.8988-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        netdev@vger.kernel.org, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751117AbdJCVco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 17:32:44 -0400
In-Reply-To: <20170928010349.8988-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 27 Sep 2017 18:03:49 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Some NIC drivers don't have correct speed/duplex settings at the
> time they send NETDEV_UP notification and that messes up the
> bonding state. Especially 802.3ad mode which is very sensitive
> to these settings. In the current implementation we invoke
> bond_update_speed_duplex() when we receive NETDEV_UP, however,
> ignore the return value. If the values we get are invalid
> (UNKNOWN), then slave gets removed from the aggregator with
> speed and duplex set to UNKNOWN while link is still marked as UP.
> 
> This patch fixes this scenario. Also 802.3ad mode is sensitive to
> these conditions while other modes are not, so making sure that it
> doesn't change the behavior for other modes.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
