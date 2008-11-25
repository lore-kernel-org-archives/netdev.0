From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 01/03: ctnetlink: fix conntrack creation race
Date: Mon, 24 Nov 2008 16:05:47 -0800 (PST)
Message-ID: <20081124.160547.137623297.davem@davemloft.net>
References: <20081124134427.462.77824.sendpatchset@x2.localnet>
	<20081124134428.462.23305.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081124134428.462.23305.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 24 Nov 2008 14:44:36 +0100 (MET)

>     netfilter: ctnetlink: fix conntrack creation race
>     
>     Conntrack creation through ctnetlink has two races:
>     
>     - the timer may expire and free the conntrack concurrently, causing an
>       invalid memory access when attempting to put it in the hash tables
>     
>     - an identical conntrack entry may be created in the packet processing
>       path in the time between the lookup and hash insertion
>     
>     Hold the conntrack lock between the lookup and insertion to avoid this.
>     
>     Reported-by: Zoltan Borbely <bozo@andrews.hu>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 

Applied.
