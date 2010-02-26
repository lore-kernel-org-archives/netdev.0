From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][KS8695] Mark network interface as running on ifconfig
 up
Date: Fri, 26 Feb 2010 01:20:57 -0800 (PST)
Message-ID: <20100226.012057.51272829.davem@davemloft.net>
References: <4B73E62B.3030305@visionsystems.de>
	<20100216.160647.208330407.davem@davemloft.net>
	<4B82A72E.50508@visionsystems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, avictor.za@gmail.com,
	netdev@vger.kernel.org
To: yegor_sub1@visionsystems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935653Ab0BZJUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:20:40 -0500
In-Reply-To: <4B82A72E.50508@visionsystems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegor_sub1@visionsystems.de>
Date: Mon, 22 Feb 2010 16:47:58 +0100

> [KS8695] Don't call netif_carrier_off() from ndo_stop()
> 
> netif_carrier_on() and netif_carrier_off() should be called from
> link status interrupt handler
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Looks good, applied.

Please do not put text you want to make it into the
commit message header line in brackets "[]", those
get removed by automated tools that apply patches
because patches are usually posted as:

Subject: [PATCH N/M] xxxx

and the GIT tools kill all the text inside of the brackets
so that the commit header properly reads "xxx"

Thanks.
