From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: documents timewait refcnt tricks
Date: Tue, 08 Dec 2009 20:20:19 -0800 (PST)
Message-ID: <20091208.202019.169120898.davem@davemloft.net>
References: <20091205212148.GA26270@ioremap.net>
	<4B1CD20D.8030407@gmail.com>
	<4B1D2822.5030704@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, zbr@ioremap.net, kdakhane@gmail.com,
	netdev@vger.kernel.org, netfilter@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B1D2822.5030704@xenotime.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 07 Dec 2009 08:06:58 -0800

> Eric Dumazet wrote:
>> Evgeniy Polyakov a écrit :
>> [PATCH] tcp: documents timewait refcnt tricks 
>> 
>> Adds kerneldoc for inet_twsk_unhash() & inet_twsk_bind_unhash().
>> 
>> Suggested-by: Evgeniy Polyakov <zbr@ioremap.net>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
>> + *	unhash a timewait socket from established hash, if hashed.
>> + *	ehash lock must be hold by caller.
> 
> 	                   held
> 
 ...
>> + *	unhash a timewait socket from bind hash, if hashed.
>> + *	bind hash lock must be hold by caller.
> 
> 	                       held

I've applied the patch with Randy's corrections added.
