From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: don't read beyond unicast address list
Date: Wed, 12 Jul 2017 14:42:22 -0700 (PDT)
Message-ID: <20170712.144222.1359946377809355868.davem@davemloft.net>
References: <b8c7ef9e-6c6e-1b59-c911-728089682258@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754191AbdGLVmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 17:42:23 -0400
In-Reply-To: <b8c7ef9e-6c6e-1b59-c911-728089682258@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Wed, 12 Jul 2017 17:19:41 +0100

> If we have more than 32 unicast MAC addresses assigned to an interface
> we will read beyond the end of the address table in the driver when
> adding filters. The next 256 entries store multicast addresses, so we
> will end up attempting to insert duplicate filters, which is mostly
> harmless. If we add more than 288 unicast addresses we will then read
> past the multicast address table, which is likely to be more exciting.
> 
> Fixes: 12fb0da45c9a ("sfc: clean fallbacks between promisc/normal in efx_ef10_filter_sync_rx_mode")
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied and queued up for -stable, thanks.
