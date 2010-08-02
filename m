From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Mon, 02 Aug 2010 09:10:11 -0700
Message-ID: <1280765411.22830.15.camel@localhost.localdomain>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com>
	 <1280442682.9058.15.camel@localhost.localdomain>
	 <20100801083113.GB16158@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100801083113.GB16158@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

On Sun, 2010-08-01 at 11:31 +0300, Michael S. Tsirkin wrote:
> Could you provide an example of a good setup?
> Specifically, is it a good idea for the vhost thread
> to inherit CPU affinities from qemu? 

I need to retest my set up with multi-threads vhost. My previous set up
applies to single thread vhost. The single stream netperf/netserver set
up, for example, if we have two quad-cores sockets to get the consistent
9.4Gb/s BW:

socket 1:
cpu0: netperf/netserver
cpu1: ixgbe 10GbE NIC IRQ 
cpu2: I/O thread
cpu3: vhost thread

socket 2:
cpu0: QEMU VCPU0
cpu1: QEMU VCPU1
cpu2:
cpu3:

Thanks
Shirley

