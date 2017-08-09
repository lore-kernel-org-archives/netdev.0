From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] netvsc: make sure and unregister datapath
Date: Tue, 08 Aug 2017 18:10:17 -0700 (PDT)
Message-ID: <20170808.181017.2134405221971495235.davem@davemloft.net>
References: <20170807183000.10827-1-sthemmin@microsoft.com>
        <20170807183000.10827-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbdHIBKS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:10:18 -0400
In-Reply-To: <20170807183000.10827-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon,  7 Aug 2017 11:30:00 -0700

> Go back to switching datapath directly in the notifier callback.
> Otherwise datapath might not get switched on unregister.
> 
> No need for calling the NOTIFY_PEERS notifier since that is only for
> a gratitious ARP/ND packet; but that is not required with Hyper-V
> because both VF and synthetic NIC have the same MAC address.
> 
> Reported-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> Fixes: 0c195567a8f6 ("netvsc: transparent VF management")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks Stephen.
