From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next] tun/macvtap: use consume_skb() instead of
 kfree_skb() when needed
Date: Fri, 05 Dec 2014 21:45:41 -0800 (PST)
Message-ID: <20141205.214541.1925832989861326040.davem@davemloft.net>
References: <1417423995-4765-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, eric.dumazet@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417423995-4765-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon,  1 Dec 2014 16:53:15 +0800

> To be more friendly with drop monitor, we should only call kfree_skb() when
> the packets were dropped and use consume_skb() in other cases.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
