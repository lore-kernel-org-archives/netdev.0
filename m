From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/02] core: enable more fine-grained datagram
 reception control
Date: Sun, 06 Dec 2015 23:30:38 -0500 (EST)
Message-ID: <20151206.233038.1580536748391971635.davem@davemloft.net>
References: <874mfv7055.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874mfv7055.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Sun, 06 Dec 2015 21:11:34 +0000

> The __skb_recv_datagram routine in core/ datagram.c provides a general
> skb reception factility supposed to be utilized by protocol modules
> providing datagram sockets. It encompasses both the actual recvmsg code
> and a surrounding 'sleep until data is available' loop. This is
> inconvenient if a protocol module has to use additional locking in order
> to maintain some per-socket state the generic datagram socket code is
> unaware of (as the af_unix code does). The patch below moves the recvmsg
> proper code into a new __skb_try_recv_datagram routine which doesn't
> sleep and renames wait_for_more_packets to
> __skb_wait_for_more_packets, both routines being exported interfaces. The
> original __skb_recv_datagram routine is reimplemented on top of these
> two functions such that its user-visible behaviour remains unchanged.
> 
> Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Applied to net-next.
