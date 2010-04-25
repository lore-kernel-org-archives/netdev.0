From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH v4 00/18] Provide a zero-copy method on KVM
 virtio-net.
Date: Sun, 25 Apr 2010 02:55:29 -0700 (PDT)
Message-ID: <20100425.025529.123989625.davem@davemloft.net>
References: <1272187206-18534-17-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-18-git-send-email-xiaohui.xin@intel.com>
	<1272187206-18534-19-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-19-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: xiaohui.xin@intel.com
Date: Sun, 25 Apr 2010 17:20:06 +0800

> The idea is simple, just to pin the guest VM user space and then let
> host NIC driver has the chance to directly DMA to it.

Isn't it much easier to map the RX ring of the network device into the
guest's address space, have DMA map calls translate guest addresses to
physical/DMA addresses as well as do all of this crazy page pinning
stuff, and provide the translations and protections via the IOMMU?

What's being proposed here looks a bit over-engineered.
