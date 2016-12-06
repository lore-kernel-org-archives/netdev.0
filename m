From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: Fix DMA-from-the-stack in
 virtnet_set_mac_address()
Date: Tue, 06 Dec 2016 11:39:01 -0500 (EST)
Message-ID: <20161206.113901.1729006808840379027.davem@davemloft.net>
References: <fe889e578d5dffa9ae0834b449a35fcfd1e10694.1480990173.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, mst@redhat.com,
        jasowang@redhat.com, labbott@redhat.com
To: luto@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fe889e578d5dffa9ae0834b449a35fcfd1e10694.1480990173.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@kernel.org>
Date: Mon,  5 Dec 2016 18:10:58 -0800

> With CONFIG_VMAP_STACK=y, virtnet_set_mac_address() can be passed a
> pointer to the stack and it will OOPS.  Copy the address to the heap
> to prevent the crash.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Reported-by: zbyszek@in.waw.pl
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Applied, thanks.
