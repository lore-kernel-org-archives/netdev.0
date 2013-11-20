From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 fragmentation-related panic in netfilter
Date: Wed, 20 Nov 2013 15:43:33 -0500 (EST)
Message-ID: <20131120.154333.863504215748882182.davem@davemloft.net>
References: <19807032.ebUJct12DE@h2o.as.studentenwerk.mhn.de>
	<20131119124032.GS16541@order.stressinduktion.org>
	<3998760.5g9L5dp08X@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, kaber@trash.net,
	steffen.klassert@secunet.com, tmshlvck@gmail.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: linux@stwm.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <3998760.5g9L5dp08X@h2o.as.studentenwerk.mhn.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Walter <linux@stwm.de>
Date: Tue, 19 Nov 2013 23:27:40 +0100

> Am Dienstag, 19. November 2013, 13:40:32 schrieb Hannes Frederic Sowa:
>> Yes, see here:
>> 
>> http://patchwork.ozlabs.org/patch/288967/
>> http://patchwork.ozlabs.org/patch/288970/
>> 
> 
> This fixed it. The second patch did not cleanly apply to 3.12 due to
> formatting changes or because some functions in 3.12 get
> 
> 	unsigned int hooknum
> 
> instead of
> 
> 	const struct nf_hook_ops *ops
> 
> I hopefully got it right:at least it works and no crashes any more :-).
> 
> I hope both patches go into stable soon.

They are both queued up.
