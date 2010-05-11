From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: virtio: power management
Date: Tue, 11 May 2010 21:12:21 +0300
Message-ID: <20100511181221.GA9361@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, gleb@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anyone looked at power management with virtio?
virtio-pci has callbacks to save/restore pci config
on suspend/resume, but it seems that more action,
such as restoring queue state, would be needed
for e.g. suspend to disk to work.

Rusty, any hints on the code in virtio-pci
that deals with suspend? Is it incomplete?

Thanks,

-- 
MST
