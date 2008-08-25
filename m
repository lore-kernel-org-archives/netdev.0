From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] bnx2x: Minimize lock time
Date: Mon, 25 Aug 2008 15:23:06 -0700 (PDT)
Message-ID: <20080825.152306.205588648.davem@davemloft.net>
References: <1219674275.19456.29.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753235AbYHYWXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:23:10 -0400
In-Reply-To: <1219674275.19456.29.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 25 Aug 2008 17:24:35 +0300

> After iSCSI boot, the HW lock should only protect the flag so only the
> first function will reset the chip and not then entire chip reset
> process
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.

> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 2e207b8..9972d0c 100755

Again, please fix these execute permission bits.
