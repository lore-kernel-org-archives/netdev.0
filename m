From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] macvtap: switch to use skb array
Date: Fri, 15 Jul 2016 14:41:04 -0700 (PDT)
Message-ID: <20160715.144104.184679049933030447.davem@davemloft.net>
References: <1468568791-30024-1-git-send-email-jasowang@redhat.com>
	<1468568791-30024-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468568791-30024-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 15 Jul 2016 03:46:31 -0400

> This patch switch to use skb array instead of sk_receive_queue to
> avoid spinlock contentions. Tests shows about 21% improvements for
> guest rx pps:
> 
> Before: 1472731 pkts/s
> After:  1786289 pkts/s
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Looks great, nice work.

Applied, thanks Jason.
