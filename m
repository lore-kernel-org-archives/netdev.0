From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: fix issues of iovec iterators using in
 tun_put_user()
Date: Thu, 13 Nov 2014 14:35:51 -0500 (EST)
Message-ID: <20141113.143551.1032729786667755501.davem@davemloft.net>
References: <1415868854-4913-1-git-send-email-jasowang@redhat.com>
	<20141113085838.GA3070@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141113085838.GA3070@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Nov 2014 16:58:38 +0800

> On Thu, Nov 13, 2014 at 04:54:14PM +0800, Jason Wang wrote:
>> This patch fixes two issues after using iovec iterators:
>> - vlan_offset should be initialized to zero, otherwise unexpected offset
>>   will be used in skb_copy_datagram_iter()
>> - advance iovec iterator when vnet_hdr_sz is greater than sizeof(gso), this
>>   is the case when mergeable rx buffer were enabled for a virt guest.
>> 
>> Fixes e0b46d0ee9c240c7430a47e9b0365674d4a04522 ("tun: Use iovec iterators")
>> Cc: Herbert Xu <herbert@gondor.apana.org.au>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Good catch.
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
