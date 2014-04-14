From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 18:51:52 -0400 (EDT)
Message-ID: <20140414.185152.204599887297456936.davem@davemloft.net>
References: <1397502396.4222.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140414.152225.1983723140136958968.davem@davemloft.net>
	<1397510604.4222.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397510604.4222.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Apr 2014 14:23:24 -0700

> I was trying to cook a not too invasive patch.
> 
> Changing ip_local_out() means changing dst_output() / nf_hook()  and
> hundred of call sites.
> 
> Unless I misunderstood you ?

You could make ip_local_out(skb) be __ip_local_out(skb, skb->sk) and
make tunnel output use __ip_local_out().
