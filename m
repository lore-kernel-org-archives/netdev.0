From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enic: Store permanent MAC address during probe()
Date: Wed, 22 Mar 2017 11:26:49 -0700 (PDT)
Message-ID: <20170322.112649.1805832210360686563.davem@davemloft.net>
References: <20170320224120.24484-1-pjw@netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com,
        _govind@gmx.com, neepatel@cisco.com
To: pjwaskiewicz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965271AbdCVS0u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:26:50 -0400
In-Reply-To: <20170320224120.24484-1-pjw@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
Date: Mon, 20 Mar 2017 15:41:20 -0700

> From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
> 
> The permanent MAC address is useful to store for things like ethtool,
> and when bonding with modes such as active/passive or LACP.  This
> follows the model of other Ethernet drivers, such as ixgbe.
> 
> This was verified on a C220 chassis with the Cisco VNIC Ethernet device.
> 
> Signed-off-by: PJ Waskiewicz <pjwaskiewicz@gmail.com>

As per the discussion, upstream fixes this generically, so I'm dropping
this.
