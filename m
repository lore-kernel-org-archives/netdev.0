From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] net: drop the packet when fails to do software
 segmentation or header check
Date: Thu, 18 Dec 2014 23:02:26 -0500 (EST)
Message-ID: <20141218.230226.442587581329380880.davem@davemloft.net>
References: <1418958553-9962-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418958553-9962-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 19 Dec 2014 11:09:13 +0800

> Commit cecda693a969816bac5e470e1d9c9c0ef5567bca ("net: keep original skb
> which only needs header checking during software GSO") keeps the original
> skb for packets that only needs header check, but it doesn't drop the
> packet if software segmentation or header check were failed.
> 
> Fixes cecda693a9 ("net: keep original skb which only needs header checking
> during software GSO")
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.
