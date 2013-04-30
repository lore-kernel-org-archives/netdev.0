From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] unix/dgram: peek beyond 0-sized skbs
Date: Tue, 30 Apr 2013 00:44:08 -0400 (EDT)
Message-ID: <20130430.004408.1248228240476926838.davem@davemloft.net>
References: <kll5si$544$1@ger.gmane.org>
	<1367271734-14379-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, xemul@parallels.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367271734-14379-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Mon, 29 Apr 2013 17:42:12 -0400

> "77c1090 net: fix infinite loop in __skb_recv_datagram()" (v3.8) introduced a
> regression:
> After that commit, recv can no longer peek beyond a 0-sized skb in the queue.
> __skb_recv_datagram() instead stops at the first skb with len == 0 and results
> in the system call failing with -EFAULT via skb_copy_datagram_iovec().
> 
> When peeking at an offset with 0-sized skb(s), each one of those is received
> only once, in sequence. The offset starts moving forward again after receiving
> datagrams with len > 0.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

Applied.
