From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v0 1/7] gianfar: Add per queue structure support
Date: Tue, 20 Oct 2009 00:56:46 -0700 (PDT)
Message-ID: <20091020.005646.227664762.davem@davemloft.net>
References: <20091019.231633.25328647.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B8940DB@zin33exm22.fsl.freescale.net>
	<20091020.000358.53030357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sandeep.Kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885AbZJTH4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 03:56:23 -0400
In-Reply-To: <20091020.000358.53030357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 20 Oct 2009 00:03:58 -0700 (PDT)

> From: "Kumar Gopalpet-B05799" <Sandeep.Kumar@freescale.com>
> Date: Tue, 20 Oct 2009 12:15:14 +0530
> 
>> I am assuming all the 7 patches are applied.
> 
> I am going to add them, yes.

Nevermind, these patches don't apply to net-next-2.6 at all
and will need to be respun.

For example, patch #1 rejects because gfar_suspend() in
net-next-2.6 takes a 'dev' not an 'ofdev'.
