From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: TSO workaround fixes.
Date: Tue, 20 Feb 2007 22:56:32 -0800 (PST)
Message-ID: <20070220.225632.108742185.davem@davemloft.net>
References: <1172029816.3644.4.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751143AbXBUG4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 01:56:34 -0500
In-Reply-To: <1172029816.3644.4.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 20 Feb 2007 19:50:15 -0800

> [TG3]: TSO workaround fixes.
> 
> 1.  Add race condition check after netif_stop_queue().  tg3_tx() runs
>     without netif_tx_lock and can race with tg3_start_xmit_dma_bug() ->
>     tg3_tso_bug().
> 
> 2.  Firmware TSO in 5703/5704/5705 also have the same TSO limitation,
>     i.e. they cannot handle TSO headers bigger than 80 bytes.  Rename
>     TG3_FL2_HW_TSO_1_BUG to TG3_FL2_TSO_BUG and set this flag on
>     these chips as well.
> 
> 3.  Update version to 3.74.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks good, applied, thanks Micahel.
