From: David Miller <davem@davemloft.net>
Subject: Re: multicast routing and multiple interfaces with same IP
Date: Sat, 29 Aug 2009 00:01:54 -0700 (PDT)
Message-ID: <20090829.000154.263733862.davem@davemloft.net>
References: <1b9338490908111626j55b49177q71b8a373b6e6381b@mail.gmail.com>
	<200908270253.19132.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mail4ilia@gmail.com, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbZH2HBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:01:40 -0400
In-Reply-To: <200908270253.19132.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Thu, 27 Aug 2009 02:53:18 +0300

> I don't have context on multicast routing, but this caught my attention:
> 
>>@@ -61,11 +61,13 @@ 
>> 	unsigned int vifc_rate_limit;	/* Rate limiter values (NI) */
>> 	struct in_addr vifc_lcl_addr;	/* Our address */
>> 	struct in_addr vifc_rmt_addr;	/* IPIP tunnel addr */
>>+	int ifindex;			/* Local interface index */
>> };
>>
> 
> Wouldn't this break userspace ABI? 
> 
> Perhaps you could use a union between vifc_lcl_addr and vifc_ifindex, they seem 
> to be exclusive.

Indeed, this will need to be fixed up.
