From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] adapt DPAA drivers for DSA
Date: Wed, 18 Oct 2017 13:45:04 +0100 (WEST)
Message-ID: <20171018.134504.1506752039585315800.davem@davemloft.net>
References: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, junote@outlook.com,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60768 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934902AbdJRMpQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:45:16 -0400
In-Reply-To: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Mon, 16 Oct 2017 21:36:04 +0300

> Junote Cai reported that he was not able to get a DSA setup involving the
> DPAA/FMAN driver to work and narrowed it down to of_find_net_device_by_node()
> call in DSA setup. The initial attempt to fix this by adding of_node to the
> platform device results in a second, failed, probing of the FMan MAC driver
> against the new platform device created for the DPAA Ethernet driver.
> Solve these issues by removing the of_node pointer from the platform device
> and changing the net_dev dev to the of_device dev to ensure the DSA init
> will be able to find the DPAA net_dev using of_find_net_device_by_node().
> Several changes were required to enable this solution: refactoring the
> adjust_link (also resulted in lesser, cleaner code) and renaming the fman
> kernel modules to keep the legacy udev rules happy.
> 
> Changes in v2:
> 
>  - fix issue on error path in "dpaa_eth: change device used" patch
>  - cleanup the dpaa_eth_probe() error paths
> 
> Changes in v3:
> 
>  - remove obsolete comment in moved code
>  - add explanation for module rename

Series applied.
