From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in
 __skb_try_recv_datagram
Date: Tue, 29 Dec 2015 15:08:43 -0500 (EST)
Message-ID: <20151229.150843.2021692616139434395.davem@davemloft.net>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	<87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob@teenage.engineering, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, edumazet@google.com,
	khlebnikov@yandex-team.ru, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Tue, 29 Dec 2015 19:42:36 +0000

> Jacob Siverskog <jacob@teenage.engineering> writes:
>> This should fix a NULL pointer dereference I encountered (dump
>> below). Since __skb_unlink is called while walking,
>> skb_queue_walk_safe should be used.
> 
> The code in question is:
 ...
> __skb_unlink is only called prior to returning from the function.
> Consequently, it won't affect the skb_queue_walk code.

Agreed, this patch doesn't fix anything.
