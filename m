From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] net: keep original skb which only needs
 header checking during software GSO
Date: Mon, 22 Sep 2014 14:57:36 -0400 (EDT)
Message-ID: <20140922.145736.1677768375039003963.davem@davemloft.net>
References: <1411113878-11910-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411113878-11910-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 19 Sep 2014 16:04:38 +0800

> Commit ce93718fb7cdbc064c3000ff59e4d3200bdfa744 ("net: Don't keep
> around original SKB when we software segment GSO frames") frees the
> original skb after software GSO even for dodgy gso skbs. This breaks
> the stream throughput from untrusted sources, since only header
> checking was done during software GSO instead of a true
> segmentation. This patch fixes this by freeing the original gso skb
> only when it was really segmented by software.
> 
> Fixes ce93718fb7cdbc064c3000ff59e4d3200bdfa744 ("net: Don't keep
> around original SKB when we software segment GSO frames.")
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jeff.
