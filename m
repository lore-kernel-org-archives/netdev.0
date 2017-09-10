From: Benoit Panizzon <benoit.panizzon@imp.ch>
Subject: broken vlan support on Realtek RTL8111/8168/8411 rev 9
Date: Sun, 10 Sep 2017 19:16:45 +0200
Message-ID: <20170910191645.549d2a3a@krup.woody.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thor.imp.ch ([157.161.4.18]:52609 "EHLO thor.imp.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750869AbdIJRg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 10 Sep 2017 13:36:26 -0400
Received: from krup.woody.ch (wotan0.imp.ch [157.161.4.49])
        by thor.imp.ch (8.15.2/8.13.3) with ESMTPS id v8AHGlk0026677
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 19:16:48 +0200 (CEST)
        (envelope-from benoit.panizzon@imp.ch)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I make a strange observation. I have two machines.

One with a:

Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit
Ethernet Controller (rev 02)

The other one with the same card, but (rev 09).

The rev 02 one works flawlessly.

The rev 09 one does set all vlan tags to zero on rx!

It's not a config error on the switch, I swapped interfaces with the
one the other card is working.

I did try the r8169 kernel module from Realtek stead of the r8168 one,
the problem persists.

I did try to disable vlan offloading:

rx-vlan-offload: on
tx-vlan-offload: on

It's not marked as fixed but:

when I try to turn offloading off I get:

# /sbin/ethtool -K eth0 rx-vlan-offload off
ethtool: bad command line argument(s)
For more information run ethtool -h

Could anyone give me a hint how to further debug the problem or disable
vlan offloading completely?

-Benoit-
