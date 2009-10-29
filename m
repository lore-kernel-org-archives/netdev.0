From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 03:43:42 -0700 (PDT)
Message-ID: <20091029.034342.122859203.davem@davemloft.net>
References: <9F4C7D19E8361D4C94921B95BE08B81B95035E@zin33exm22.fsl.freescale.net>
	<20091029.031610.04742718.davem@davemloft.net>
	<9F4C7D19E8361D4C94921B95BE08B81B950364@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com
To: B05799@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980AbZJ2KnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:43:18 -0400
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81B950364@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Date: Thu, 29 Oct 2009 16:03:30 +0530

> The PATCH v2 series applied cleanly to the above clone.

It absolutely does NOT!

And I just tried it again to verify this, and you can try it yourself:

	http://vger.kernel.org/~davem/bundle-640.mbox

davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff bundle-640.mbox 
Applying: gianfar: Add per queue structure support
Applying: gianfar: Introduce logical group support.
Applying: gianfar: Add Multiple Queue Support
Applying: fsl_pq_mdio: Add Suport for etsec2.0 devices.
error: patch failed: drivers/net/fsl_pq_mdio.c:405
error: drivers/net/fsl_pq_mdio.c: patch does not apply
Patch failed at 0004 fsl_pq_mdio: Add Suport for etsec2.0 devices.
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
davem@sunset:~/src/GIT/net-next-2.6$ 

So stop telling me it applies cleanly.

Because I've tried to do it multiple times and it absolutely does not.
