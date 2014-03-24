From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] gianfar: Fix P1010 config regression (SQ
 polling)
Date: Mon, 24 Mar 2014 00:41:16 -0400 (EDT)
Message-ID: <20140324.004116.527168313404769449.davem@davemloft.net>
References: <20140320.160944.268619450160968028.davem@davemloft.net>
	<1395387197-25086-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaCXElR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 00:41:17 -0400
In-Reply-To: <1395387197-25086-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 21 Mar 2014 09:33:17 +0200

> The P1010 device tree restricts the number of
> supported interrupt groups to 1, although the eth
> controller can support 2 interrupt groups and the
> driver assumes the Multi-Group mode ("fsl,etsec2" model).
> 
> So, in this case the assumption that the Multi-Group
> mode (MQ_MG_MODE) devices always support 2 interrupt
> groups is false.  To fix this, a check for the actual
> number of interrupt groups enabled in the board's
> device tree has been added in gfar_probe for the
> "fsl,etsec2" devices.
> 
> Without this fix, P1010 based boards claim support for
> 2 Tx queues to the net stack but only one is actually
> allocated, leading to NULL access in xmit.  This issue
> was introduced by enabling Single-Queue polling for
> the P1010 devices.
> (71ff9e3 gianfar: Use Single-Queue polling for
> "fsl,etsec2")
> 
> Fixes: 71ff9e3df7e1c5d3293af6b595309124e8c97412
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied, thanks.
