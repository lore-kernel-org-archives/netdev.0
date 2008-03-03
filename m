From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26][ARP]: Introduce the arp_hdr_len helper.
Date: Mon, 03 Mar 2008 12:21:10 -0800 (PST)
Message-ID: <20080303.122110.111551253.davem@davemloft.net>
References: <47CBD968.5010008@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750870AbYCCUVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:21:25 -0500
In-Reply-To: <47CBD968.5010008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 03 Mar 2008 13:56:40 +0300

> There are some place, that calculate the ARP header length. These
> calculations are correct, but 
>  a) some operate with "magic" constants,
>  b) enlarge the code length (sometimes at the cost of coding style),
>  c) are not informative from the first glance.
> 
> The proposal is to introduce a helper, that includes all the good
> sides of these calculations.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Looks good, applied.
