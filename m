From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/2] liquidio: switchdev support for
 LiquidIO NIC
Date: Wed, 01 Nov 2017 11:40:09 +0900 (KST)
Message-ID: <20171101.114009.117159467888124203.davem@davemloft.net>
References: <20171031230420.GA3615@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        vijaya.guvva@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:40:13 -0400
In-Reply-To: <20171031230420.GA3615@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 31 Oct 2017 16:04:20 -0700

> From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
> 
> patch1 of this patch set adds switchdev support for SRIOV capable
> LiquidIO NIC, so that for every SRIOV VF on LiquidIO, a representor
> netdev is created on hypervisor. It also has changes to send representor
> interface configurations like admin state and MTU to LiquidIO firmware and
> to retrieve HW counted VF stats for VF representor.
> 
> patch2 adds support for switchdev enable/disable from devlink
> 
> Patchset Change Log:
>   V2 -> V3:
>     * Use mac address as the physical switchID.
>     * Check for eswitch_mode before returning switchID
> 
>   V1 -> V2:
>     * Name the representors "pfXvfY".
>     * Drop patch3 (ethtool support for switchdev ports) that was in V1
>       because it's not necessary.

Series applied, thanks.
