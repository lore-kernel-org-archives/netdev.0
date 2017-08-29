From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] liquidio: show NIC's U-Boot version in a
 dev_info() message
Date: Tue, 29 Aug 2017 16:09:18 -0700 (PDT)
Message-ID: <20170829.160918.198738849211591017.davem@davemloft.net>
References: <20170829191957.GA12243@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        weilin.chang@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41114 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdH2XJT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:09:19 -0400
In-Reply-To: <20170829191957.GA12243@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 29 Aug 2017 12:19:57 -0700

> From: Weilin Chang <weilin.chang@cavium.com>
> 
> Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
> Patch Change Log:
>   V1 -> V2:
>     * Move octeon_get_uboot_version() to a proper place to avoid forward
>       declaration.
>     * Remove complicated for-loops that search for substrings; replace them
>       with calls to strstr().
>     * Don't add unnecessary fields to struct octeon_device.

Applied.
