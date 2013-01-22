From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH V6 1/3] virtio-net: fix the set affinity bug when CPU IDs are not consecutive
Date: Tue, 22 Jan 2013 11:42:40 +1030
Message-ID: <87hamavx4n.fsf@rustcorp.com.au>
References: <1358767524-17934-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	Wanlong Gao <gaowanlong@cn.fujitsu.com>
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358767524-17934-1-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wanlong Gao <gaowanlong@cn.fujitsu.com> writes:

> As Michael mentioned, set affinity and select queue will not work very
> well when CPU IDs are not consecutive, this can happen with hot unplug.
> Fix this bug by traversal the online CPUs, and create a per cpu variable
> to find the mapping from CPU to the preferable virtual-queue.

This series looks fairly sane at a glance, to me, but MST is the Ack you
need.

Thanks,
Rusty.
