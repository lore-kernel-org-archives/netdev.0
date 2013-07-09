From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] virtio_net: fix race in RX VQ processing
Date: Tue, 09 Jul 2013 12:46:14 -0700 (PDT)
Message-ID: <20130709.124614.1747764332568941574.davem@davemloft.net>
References: <1373346713-442-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, jasowang@redhat.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373346713-442-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 9 Jul 2013 08:12:57 +0300

> Jason Wang reported a race in RX VQ processing:
> virtqueue_enable_cb is called outside napi lock,
> violating virtio serialization rules.
> The race has been there from day 1, but it got especially nasty in 3.0
> when commit a5c262c5fd83ece01bd649fb08416c501d4c59d7
> "virtio_ring: support event idx feature"
> added more dependency on vq state.
> 
> Please review, and consider for 3.11 and stable.
> 
> Changes from v1:
> 	- Added Jason's Tested-by tag
> 	- minor coding style fix

Applied and queued up for -stable, thanks.

 
