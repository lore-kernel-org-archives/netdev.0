From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: copy userspace buffers on device
 forwarding
Date: Thu, 15 Sep 2011 15:08:22 -0400 (EDT)
Message-ID: <20110915.150822.1432876015378023873.davem@davemloft.net>
References: <20110831180328.GA22016@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	jesse@nicira.com, xma@us.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110831180328.GA22016@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 31 Aug 2011 21:03:29 +0300

> dev_forward_skb loops an skb back into host networking
> stack which might hang on the memory indefinitely.
> In particular, this can happen in macvtap in bridged mode.
> Copy the userspace fragments to avoid blocking the
> sender in that case.
> 
> As this patch makes skb_copy_ubufs extern now,
> I also added some documentation and made it clear
> the SKBTX_DEV_ZEROCOPY flag automatically instead
> of doing it in all callers. This can be made into a separate
> patch if people feel it's worth it.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
