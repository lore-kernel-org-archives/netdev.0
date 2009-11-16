From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] bnx2x: Handle Rx and Tx together in NAPI
Date: Mon, 16 Nov 2009 03:05:04 -0800 (PST)
Message-ID: <20091116.030504.268003197.davem@davemloft.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B950BEF@zin33exm22.fsl.freescale.net>
	<20091116.024130.156214496.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B950BFF@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751864AbZKPLEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:04:48 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950BFF@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Mon, 16 Nov 2009 16:33:56 +0530

> I was talking about an independent napi routine for cleaning tx ring, I
> do not want to mix the rx and tx clean ring processes.

But you absolutely should do this, it will give optimal performance.
