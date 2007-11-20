From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6 net-2.6.25][RAW] Consolidate proc interface (v2)
Date: Mon, 19 Nov 2007 22:38:43 -0800 (PST)
Message-ID: <20071119.223843.100278186.davem@davemloft.net>
References: <473DB1E8.60902@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, yoshfuji@linux-ipv6.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757209AbXKTGio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:38:44 -0500
In-Reply-To: <473DB1E8.60902@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 16 Nov 2007 18:06:16 +0300

> Both ipv6/raw.c and ipv4/raw.c use the seq files to walk
> through the raw sockets hash and show them.
> 
> The "walking" code is rather huge, but is identical in both
> cases. The difference is the hash table to walk over and
> the protocol family to check (this was not in the first
> virsion of the patch, which was noticed by YOSHIFUJI)
> 
> Make the ->open store the needed hash table and the family
> on the allocated raw_iter_state and make the start/next/stop
> callbacks work with it.
> 
> This removes most of the code.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks a lot.
