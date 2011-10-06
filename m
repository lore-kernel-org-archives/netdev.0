From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 06 Oct 2011 17:56:32 -0400 (EDT)
Message-ID: <20111006.175632.863279389111584127.davem@davemloft.net>
References: <1317935310.24742.18.camel@dagon.hellion.org.uk>
	<20111006.171645.1154998655978830692.davem@davemloft.net>
	<1317936302.24742.23.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org, jdmason@kudzu.us
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab1JFV4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:56:39 -0400
In-Reply-To: <1317936302.24742.23.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Thu, 6 Oct 2011 22:25:02 +0100

> On Thu, 2011-10-06 at 22:16 +0100, David Miller wrote:
>> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
>> Date: Thu, 6 Oct 2011 22:08:30 +0100
>> 
>> > You are absolutely right, I've no idea how I missed the very obvious
>> > warning this produces. Incremental patch is below, sorry about this!
>> 
>> Would really love to know what your patch is against, since I
>> fixed this problem when I commited your original patch.
> 
> It was against e878d78b9a74 + the original bad patch, i.e.:
> 
> $ git log --pretty=oneline net-next/master^..HEAD
> 80f4b53b3d2c009689178d12de0bc108ddd580cd net: fix argument to dma_mapping_error after conversion to skb_frag_dma_map
> 669b1ce22eedd0f7bac048299feb06c67804ed83 net: use DMA_x_DEVICE and dma_mapping_error with skb_frag_dma_map
> e878d78b9a7403fabc89ecc93c56928b74d14f01 virtio-net: Verify page list size before fitting into skb
> 
> AFAICT e878d78b9a7403fabc89ecc93c56928b74d14f01 is still the head of the
> public git://github.com/davem330/net-next master.

I'm and idiot, I didn't push it out when I left the office :-/

Sorry.

But when your commit appears it will have the dma_mapping_error() stuff
fixed up, so don't worry about it. :-)
