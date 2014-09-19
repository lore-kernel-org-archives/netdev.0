From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2] net: keep original skb which only needs
 header checking during software GSO
Date: Fri, 19 Sep 2014 05:46:48 -0700
Message-ID: <1411130808.7106.302.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411113878-11910-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411113878-11910-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-09-19 at 16:04 +0800, Jason Wang wrote:
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
