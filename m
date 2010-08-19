From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vxge: Implement 64bit stats
Date: Thu, 19 Aug 2010 00:17:10 -0700 (PDT)
Message-ID: <20100819.001710.137834207.davem@davemloft.net>
References: <1282138974.2194.83.camel@edumazet-laptop>
	<20100818225330.GJ17009@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Ramkrishna.Vepa@exar.com, Sivakumar.Subramani@exar.com,
	Sreenivasa.Honnur@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab0HSHQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:16:51 -0400
In-Reply-To: <20100818225330.GJ17009@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Wed, 18 Aug 2010 17:53:31 -0500

> On Wed, Aug 18, 2010 at 06:42:54AM -0700, Eric Dumazet wrote:
>> vxge_get_stats() is racy, since it clears a block of memory (net_stats)
>> possibly still used by other cpus.
>> 
>> We can update this driver to full 64bit stats, since ndo_get_stats64()
>> provides a private block to store results, and driver maintains 64bit
>> counters already.
>> 
>> We also remove net_stats field from struct vxge_sw_stats
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Jon Mason <jon.mason@exar.com>

Applied, thanks everyone.
