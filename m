From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: fix use after free
Date: Wed, 15 Oct 2014 16:47:27 -0400 (EDT)
Message-ID: <20141015.164727.298073723527552510.davem@davemloft.net>
References: <1413378878-28118-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	jasowang@redhat.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413378878-28118-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 15 Oct 2014 16:23:28 +0300

> You used __netif_subqueue_stopped but that seems to use
> a slightly more expensive test_bit internally.

More expensive in what sense?  It should be roughly the same
as "x & y" sans the volatile.

Anyways I'm ambivalent and I want to see this bug fixes, so I'll
apply your patch.

Thanks!
