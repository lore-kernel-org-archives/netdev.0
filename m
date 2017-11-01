From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: support rx-fcs and rx-all
Date: Wed, 01 Nov 2017 21:27:32 +0900 (KST)
Message-ID: <20171101.212732.279139706412586511.davem@davemloft.net>
References: <9ab2b13c-dbcd-5769-0a5d-08162569369d@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754560AbdKAM1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:27:35 -0400
In-Reply-To: <9ab2b13c-dbcd-5769-0a5d-08162569369d@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 31 Oct 2017 14:29:47 +0000

> Ethernet FCS inclusion (rx-fcs) is supported on EF10 NICs, conditional on
>  a firmware capability bit (MC_CMD_GET_CAPABILITIES_OUT_RX_INCLUDE_FCS).
> To receive frames with bad FCS (rx-all) we just don't return the discard
>  flag EFX_RX_PKT_DISCARD from efx_ef10_handle_rx_event_errors() or
>  efx_farch_handle_rx_not_ok().
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied.
