From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: unable to handle kernel NULL pointer dereference in skb_dequeue
Date: Fri, 10 Dec 2010 22:30:25 +0100
Message-ID: <4D029BF1.6020709@gmail.com>
References: <aa43945b38cee751a8231084866b074d@192.168.253.23>	<1291387595.2897.350.camel@edumazet-laptop>	<201012102151.04983.nuclearcat@nuclearcat.com> <20101210.121845.70177370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nuclearcat@nuclearcat.com, eric.dumazet@gmail.com, andrej@ota.si,
	linux-kernel@vger.kernel.org, gvs@zemos.net, ramirose@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101210.121845.70177370.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
> Date: Fri, 10 Dec 2010 21:51:04 +0200
...
>> Is there any plans to queue any patch to stable?
>> pppoe is almost dead in 2.6.36.*
> 
> I'll deal with it for -stable once I evaluate this patch for upstream,
> which I haven't even gotten to yet.

This patch is here:
http://patchwork.ozlabs.org/patch/75095/

But IMHO it's buggy for the reason I mentioned. Since Andrej
didn't respond yet I'd suggest reverting of the offending
commit 55c95e738da85. If you agree with that but e.g. too busy,
let me know.

Jarek P.
