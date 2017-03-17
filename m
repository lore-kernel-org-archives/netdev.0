From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: aquantia: set net_device mtu when mtu
 is changed
Date: Thu, 16 Mar 2017 20:21:46 -0700 (PDT)
Message-ID: <20170316.202146.864329903188612962.davem@davemloft.net>
References: <1489446436-42246-1-git-send-email-darcari@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel.Belous@aquantia.com
To: darcari@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752890AbdCQD3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:29:48 -0400
In-Reply-To: <1489446436-42246-1-git-send-email-darcari@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Arcari <darcari@redhat.com>
Date: Mon, 13 Mar 2017 19:07:16 -0400

> When the aquantia device mtu is changed the net_device structure is not
> updated.  As a result the ip command does not properly reflect the mtu change.
> 
> Commit 5513e16421cb incorrectly assumed that __dev_set_mtu() was making the
> assignment ndev->mtu = new_mtu;  This is not true in the case where the driver
> has a ndo_change_mtu routine.
> 
> Fixes: 5513e16421cb ("net: ethernet: aquantia: Fixes for aq_ndev_change_mtu")
> 
> Cc: Pavel Belous <Pavel.Belous@aquantia.com>
> Signed-off-by: David Arcari <darcari@redhat.com>

Applied.
