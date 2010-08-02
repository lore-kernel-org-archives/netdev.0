From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM
 virtio-net.
Date: Mon, 02 Aug 2010 09:04:35 -0700
Message-ID: <1280765075.22830.10.camel@localhost.localdomain>
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
> I think we should explore the idea for the driver to fall back on data
> copy
> for small message sizes.
> The benefit of zero copy would then be CPU utilization on large
> messages.

Yes, we used to have 128 bytes for small copy in other driver. I saw
Xiaohui's patch here is using 64 bytes. I think we need to compare the
performance on different platform to decide what's the best for small
message size.

Thanks
Shirley

