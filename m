From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: don't try and read ef10 data on non-ef10 NIC
Date: Tue, 15 Aug 2017 17:19:45 -0700 (PDT)
Message-ID: <20170815.171945.2105794860753584290.davem@davemloft.net>
References: <45a53c3b-b578-56ed-ef41-09bef5b5519c@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
        sbrivio@redhat.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44144 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752130AbdHPATq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:19:46 -0400
In-Reply-To: <45a53c3b-b578-56ed-ef41-09bef5b5519c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Tue, 15 Aug 2017 14:55:32 +0100

> The MAC stats command takes a port ID, which doesn't exist on
> pre-ef10 NICs (5000- and 6000- series). This is extracted from the
> NIC specific data; we misinterpret this as the ef10 data structure,
> causing us to read potentially unallocated data. With a KASAN kernel
> this can cause errors with:
>    BUG: KASAN: slab-out-of-bounds in efx_mcdi_mac_stats
> 
> Fixes: 0a2ab4d988d7 ("sfc: set the port-id when calling MC_CMD_MAC_STATS")
> Reported-by: Stefano Brivio <sbrivio@redhat.com>
> Tested-by: Stefano Brivio <sbrivio@redhat.com>
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied, thanks.
