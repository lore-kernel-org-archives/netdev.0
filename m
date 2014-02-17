From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION v3.14-rc2] NULL dereference in icmp6_send()
Date: Mon, 17 Feb 2014 14:13:01 -0500 (EST)
Message-ID: <20140217.141301.1570178529590936114.davem@davemloft.net>
References: <nsxzjlp4lxm.fsf@closure.thunk.org>
	<20140217185053.GF22833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140217185053.GF22833@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 17 Feb 2014 19:50:53 +0100

> At that point the skb does not have a dst attached, so we panic in
> icmp6_send.
> 
> This is fixed here:
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=d94c1f92bbf2c42c5febd68bbea51fffeac90834

Yep I'll get this to Linus soon.
