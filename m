From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] virtio-net: Verify page list size before
 fitting into skb
Date: Thu, 06 Oct 2011 15:41:05 -0400 (EDT)
Message-ID: <20111006.154105.273839447525115710.davem@davemloft.net>
References: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rusty@rustcorp.com.au,
	mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: levinsasha928@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <levinsasha928@gmail.com>
Date: Wed, 28 Sep 2011 17:40:54 +0300

> This patch verifies that the length of a buffer stored in a linked list
> of pages is small enough to fit into a skb.
> 
> If the size is larger than a max size of a skb, it means that we shouldn't
> go ahead building skbs anyway since we won't be able to send the buffer as
> the user requested.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Cc: kvm@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Applied to net-next
