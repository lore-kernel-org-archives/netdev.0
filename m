From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 V2] net: fix 64 bit counters on 32 bit
 arches
Date: Wed, 07 Jul 2010 15:41:09 -0700 (PDT)
Message-ID: <20100707.154109.26944330.davem@davemloft.net>
References: <1278354682.2877.639.camel@edumazet-laptop>
	<1278360322.2466.90.camel@edumazet-laptop>
	<20100707.143645.135512197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756988Ab0GGWkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 18:40:55 -0400
In-Reply-To: <20100707.143645.135512197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 07 Jul 2010 14:36:45 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 05 Jul 2010 22:05:22 +0200
> 
>> [PATCH net-next-2.6 V2] net: fix 64 bit counters on 32 bit arches

Some dev_get_stats() conversions were missing, such as parisc/led,
some s390 code, usb rndis, etc.

I took care of this when integrating this patch.
