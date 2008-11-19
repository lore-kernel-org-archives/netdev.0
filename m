From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix multiple queue warning
Date: Wed, 19 Nov 2008 14:09:58 -0800 (PST)
Message-ID: <20081119.140958.44537564.davem@davemloft.net>
References: <18709.30748.784246.990265@robur.slu.se>
	<20081116.233006.128063706.davem@davemloft.net>
	<18721.12887.390889.914789@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com, robert.olsson@its.uu.se
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34954
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750747AbYKSWJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:09:58 -0500
In-Reply-To: <18721.12887.390889.914789@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Mon, 17 Nov 2008 09:59:03 +0100

> 
> David Miller writes:
> 
>  > >  This triggers with the niu driver which has 12 TX queues on our 8 CPU-core 
> 
> > Can someone cook up a patch to fix this?
> 
> Here is one suggestion...
> 
> As number of TX queues in unrelated to number of CPU's we remove this test
> and just make sure nxtq never gets exceeded.
> 
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied, thanks Robert.
