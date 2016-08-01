From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [vhost:vhost 11/15] warning: (VOP && ..) selects VHOST_RING
	which has unmet direct dependencies (NETDEVICES && ..)
Date: Tue, 2 Aug 2016 00:18:46 +0300
Message-ID: <20160802001237-mutt-send-email-mst@kernel.org>
References: <201608020449.ake06oK8%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kbuild-all@01.org,
	Stefan Hajnoczi <stefanha@redhat.com>, Asias He <asias@redhat.com>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <201608020449.ake06oK8%fengguang.wu@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 02, 2016 at 04:56:54AM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost
> head:   c4ea43c2c1779f5dde3ff5645b830c90f75ccc15
> commit: efd7eb77f631e1ed3533db7725df157a379c78ef [11/15] VSOCK: Add Makefile and Kconfig
> config: x86_64-randconfig-x005-201631 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         git checkout efd7eb77f631e1ed3533db7725df157a379c78ef
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
> warning: (VOP && CAIF_VIRTIO && VHOST_NET && VHOST_SCSI && VHOST_VSOCK && VHOST_NET && VHOST_SCSI && VHOST_VSOCK) selects VHOST_RING which has unmet direct dependencies (NETDEVICES && CAIF_VIRTIO || VIRTUALIZATION)

I don't see what is going on here.

VHOST_RING is in the same config file as VHOST_NET so it
has the same dependencies. How can one set VHOST_NET without
enabling dependencies for VHOST_RING?


> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
