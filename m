From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] A panic caused by null pointer dereference aftering
 updating to
Date: Mon, 14 Apr 2014 14:48:43 -0400 (EDT)
Message-ID: <20140414.144843.488522666550066271.davem@davemloft.net>
References: <1397498082.4222.29.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140414.140253.788885546068554928.davem@davemloft.net>
	<1397499566.4222.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nasa4836@gmail.com, jchapman@katalix.com, edumazet@google.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397499566.4222.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Apr 2014 11:19:26 -0700

> ip_local_out() doesn't use skb->sk

It does Eric.

We had just such a report with this in the backtrace, when AF_PACKET
sends over vxlan devices.

The problem is ip_mc_output().
