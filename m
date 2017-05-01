From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/esp4: Fix invalid esph pointer crash
Date: Mon, 01 May 2017 14:59:15 -0400 (EDT)
Message-ID: <20170501.145915.1070402354847439894.davem@davemloft.net>
References: <20170430133438.31962-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: ilant@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36048 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdEAS7R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:59:17 -0400
In-Reply-To: <20170430133438.31962-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <ilant@mellanox.com>
Date: Sun, 30 Apr 2017 16:34:38 +0300

> From: Ilan Tayari <ilant@mellanox.com>
> 
> Both esp_output and esp_xmit take a pointer to the ESP header
> and place it in esp_info struct prior to calling esp_output_head.
> 
> Inside esp_output_head, the call to esp_output_udp_encap
> makes sure to update the pointer if it gets invalid.
> However, if esp_output_head itself calls skb_cow_data, the
> pointer is not updated and stays invalid, causing a crash
> after esp_output_head returns.
> 
> Update the pointer if it becomes invalid in esp_output_head
> 
> Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>

Looks good, applied, thanks.
