From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] benet: use GFP_KERNEL allocations when
 possible
Date: Thu, 03 Mar 2011 12:23:52 -0800 (PST)
Message-ID: <20110303.122352.232756161.davem@davemloft.net>
References: <20110301174612.GA5927@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752594Ab1CCUXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:23:15 -0500
In-Reply-To: <20110301174612.GA5927@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Tue, 1 Mar 2011 11:46:12 -0600

> Thanks Eric.
> 
>> -----Original Message-----
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: Tuesday, March 01, 2011 9:48 AM
>> To: Khaparde, Ajit
>> Cc: netdev
>> Subject: [PATCH net-next-2.6] benet: use GFP_KERNEL allocations when
>> possible
>> 
>> Extend be_alloc_pages() with a gfp parameter, so that we use GFP_KERNEL
>> allocations instead of GFP_ATOMIC when not running in softirq context.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied.
