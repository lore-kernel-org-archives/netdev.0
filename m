From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: add XOR instruction for use with X/K
Date: Mon, 24 Sep 2012 16:50:05 -0400 (EDT)
Message-ID: <20120924.165005.1246466996061307302.davem@davemloft.net>
References: <20120924122359.GB25156@thinkbox>
	<1348494228.26828.784.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712Ab2IXUuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:50:08 -0400
In-Reply-To: <1348494228.26828.784.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Sep 2012 15:43:48 +0200

> On Mon, 2012-09-24 at 14:23 +0200, Daniel Borkmann wrote:
>> BPF_S_ANC_ALU_XOR_X has been added a while ago, but as an 'ancillary'
>> operation that is invoked through a negative offset in K within BPF
>> load operations. Since BPF_MOD has recently been added, BPF_XOR should
>> also be part of the common ALU operations. Removing BPF_S_ANC_ALU_XOR_X
>> might not be an option since this is exposed to user space.
> 
> Please note we dont expose BPF_S_ANC_ALU_XOR_X to user space.
> 
> We expose SKF_AD_ALU_XOR_X instead.
> 
> But it seems easier to leave it to keep this patch small (not touching
> various JIT implementations, even if followup are welcomed)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

I applied this, fixing the commit message to refer to SKF_AD_ALU_XOR_X
instead of BPF_S_ANC_ALU_XOR_X.
