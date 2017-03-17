From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix wrong information about link
 modes reported to ethtool
Date: Thu, 16 Mar 2017 21:40:56 -0700 (PDT)
Message-ID: <20170316.214056.1795199104687281989.davem@davemloft.net>
References: <20170316231616.GA1819@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        manish.awasthi@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751173AbdCQEmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:42:18 -0400
In-Reply-To: <20170316231616.GA1819@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 16 Mar 2017 16:16:17 -0700

> From: Manish Awasthi <manish.awasthi@cavium.com>
> 
> Information reported to ethtool about link modes is wrong for 25G NIC.  Fix
> it by checking for presence of 25G NIC, checking the link speed reported by
> NIC firmware, and then assigning proper values to the
> ethtool_link_ksettings struct.
> 
> Signed-off-by: Manish Awasthi <manish.awasthi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
