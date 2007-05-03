From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/16][BNX2]: Fix race conditions when calling
 register_netdev().
Date: Thu, 03 May 2007 13:20:25 -0700 (PDT)
Message-ID: <20070503.132025.06567594.davem@davemloft.net>
References: <1178068303.4820.35.camel@dell>
	<1178177347.4909.68.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753670AbXECUUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 16:20:25 -0400
In-Reply-To: <1178177347.4909.68.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 00:29:06 -0700

> [BNX2]: Fix race conditions when calling register_netdev().
>     
> Hot-plug scripts can call bnx2_open() as soon as register_netdev() is
> called in bnx2_init_one().  We need to call pci_set_drvdata() and
> setup everything before calling register_netdev(). netif_carrier_off()
> also needs to be moved to bnx2_open() to avoid race conditions with
> the irq.
>     
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
