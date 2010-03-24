From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2: Fix netpoll crash.
Date: Tue, 23 Mar 2010 23:20:27 -0700 (PDT)
Message-ID: <20100323.232027.38075593.davem@davemloft.net>
References: <1269385992-18525-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754683Ab0CXGUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:20:04 -0400
In-Reply-To: <1269385992-18525-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 23 Mar 2010 15:13:11 -0800

> From: Benjamin Li <benli@broadcom.com>
> 
> The bnx2 driver calls netif_napi_add() for all the NAPI structs during
> ->probe() time but not all of them will be used if we're not in MSI-X
> mode.  This creates a problem for netpoll since it will poll all the
> NAPI structs in the dev_list whether or not they are scheduled, resulting
> in a crash when we access structure fields not initialized for that vector.
> 
> We fix it by moving the netif_napi_add() call to ->open() after the number
> of IRQ vectors has been determined.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
