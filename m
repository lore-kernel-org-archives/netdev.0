From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [Patch net] bonding: use ETH_MAX_MTU as max mtu
Date: Thu, 02 Mar 2017 13:22:57 -0800
Message-ID: <14859.1488489777@famine>
References: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, daznis@gmail.com,
        lists2009@fnarfbargle.com, Jarod Wilson <jarod@redhat.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60664 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdCBWfg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 17:35:36 -0500
In-reply-to: <1488486276-24552-1-git-send-email-xiyou.wangcong@gmail.com>
Content-ID: <14858.1488489777.1@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:

>This restores the ability of setting bond device's mtu to 9000.
>
>Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
>Reported-by: daznis@gmail.com
>Reported-by: Brad Campbell <lists2009@fnarfbargle.com>
>Cc: Jarod Wilson <jarod@redhat.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>---
> drivers/net/bonding/bond_main.c | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 6321f12..8a4ba8b 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4179,6 +4179,7 @@ void bond_setup(struct net_device *bond_dev)
> 
> 	/* Initialize the device entry points */
> 	ether_setup(bond_dev);
>+	bond_dev->max_mtu = ETH_MAX_MTU;
> 	bond_dev->netdev_ops = &bond_netdev_ops;
> 	bond_dev->ethtool_ops = &bond_ethtool_ops;

Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
