From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sh-eth: use netdev stats structure and fix
 dma_map_single
Date: Tue, 07 Feb 2012 13:39:22 -0500 (EST)
Message-ID: <20120207.133922.1780982939058488698.davem@davemloft.net>
References: <1328602641.2476.12.camel@edumazet-laptop>
	<4F30ECA2.7030603@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706Ab2BGSj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:39:27 -0500
In-Reply-To: <4F30ECA2.7030603@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 07 Feb 2012 18:19:30 +0900

> Hi Eric,
> 
> 2012/02/07 17:17, Eric Dumazet wrote:
>> No need to maintain a parallel net_device_stats structure in
>> sh_eth_private, since we have a generic one in netdev
>> 
>> Fix two dma_map_single() incorrect parameters, passing skb->tail instead
>> of skb->data. Seems that there is no corresponding dmap_unmap_single()
>> calls for the moment in this driver.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>> ---
>> Please test this patch Yoshihiro before we can apply it, thanks !
> 
> Thank you for the patch.
> I tested this patch and it worked correctly on my environment.
>  - ping, NFS, FTP and read the statistics by sysfs
> 
> Tested-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
