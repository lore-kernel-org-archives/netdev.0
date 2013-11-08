From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH linux-2.6.32.y] sctp: unbalanced rcu lock in ip_queue_xmit()
Date: Fri, 8 Nov 2013 21:48:06 +0100
Message-ID: <20131108204806.GC5652@1wt.eu>
References: <1383905635-20444-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, ben@decadent.org.uk, stable@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1383905635-20444-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicolas,

On Fri, Nov 08, 2013 at 11:13:55AM +0100, Nicolas Dichtel wrote:
> The bug was introduced by commit b8710128e201 ("inet: add RCU protection to
> inet->opt") (it's a backport of upstream commit f6d8bd051c39).
> 
> In SCTP case, packet is already routed, hence we jump to the label
> 'packet_routed', but without rcu_read_lock(). After this label,
> rcu_read_unlock() is called unconditionally.

I've just queued it for 2.6.32.62. Thanks!

Willy
