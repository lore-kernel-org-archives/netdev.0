From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] virtio-net: drop NETIF_F_FRAGLIST
Date: Fri, 07 Aug 2015 00:13:26 -0700 (PDT)
Message-ID: <20150807.001326.1062649438183092058.davem@davemloft.net>
References: <1438742044-31064-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438742044-31064-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed,  5 Aug 2015 10:34:04 +0800

> virtio declares support for NETIF_F_FRAGLIST, but assumes
> that there are at most MAX_SKB_FRAGS + 2 fragments which isn't
> always true with a fraglist.
> 
> A longer fraglist in the skb will make the call to skb_to_sgvec overflow
> the sg array, leading to memory corruption.
> 
> Drop NETIF_F_FRAGLIST so we only get what we can handle.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
