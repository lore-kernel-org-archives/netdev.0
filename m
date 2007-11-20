From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPVS] Relax the module get/put in ip_vs_app.c
Date: Mon, 19 Nov 2007 22:53:00 -0800 (PST)
Message-ID: <20071119.225300.120591949.davem@davemloft.net>
References: <47415E36.8030001@openvz.org>
	<20071120022816.GL24412@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756804AbXKTGxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:53:01 -0500
In-Reply-To: <20071120022816.GL24412@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Tue, 20 Nov 2007 11:28:18 +0900

> On Mon, Nov 19, 2007 at 12:58:14PM +0300, Pavel Emelyanov wrote:
> > Both try_module_get/module_put already handle the module == NULL
> > case, so no need in manual checking.
> > 
> > This patch fits both net-2.6 and net-2.6.25.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Thanks, that looks fine to me.
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Me too, applied to net-2.6.25, thanks Pavel.
