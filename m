From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvtap: advance iov iterator when needed in
 macvtap_put_user()
Date: Fri, 21 Nov 2014 14:59:32 -0500 (EST)
Message-ID: <20141121.145932.1019989098659258075.davem@davemloft.net>
References: <1416472265-10151-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416472265-10151-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 20 Nov 2014 16:31:05 +0800

> When mergeable buffer is used, vnet_hdr_sz is greater than sizeof struct
> virtio_net_hdr. So we need advance the iov iterators in this case.
> 
> Fixes 6c36d2e26cda1ad3e2c4b90dd843825fc62fe5b4 ("macvtap: Use iovec iterators")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
