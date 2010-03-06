From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v1 3/3] Let host NIC driver to DMA to guest user space.
Date: Sat, 6 Mar 2010 09:18:49 -0800
Message-ID: <20100306091849.0e5d2a66@s6510>
References: <1267868318-19268-1-git-send-email-xiaohui.xin@intel.com>
	<1267868318-19268-2-git-send-email-xiaohui.xin@intel.com>
	<1267868318-19268-3-git-send-email-xiaohui.xin@intel.com>
	<1267868318-19268-4-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org, Zhao Yu <yzhao81@gmail.com>
To: xiaohui.xin@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1267868318-19268-4-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat,  6 Mar 2010 17:38:38 +0800
xiaohui.xin@intel.com wrote:

> From: Xin Xiaohui <xiaohui.xin@intel.com>
> 
> The patch let host NIC driver to receive user space skb,
> then the driver has chance to directly DMA to guest user
> space buffers thru single ethX interface.
> 
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Signed-off-by: Zhao Yu <yzhao81@gmail.com>
> Sigend-off-by: Jeff Dike <jdike@c2.user-mode-linux.org>
> ---
>  include/linux/netdevice.h |   76 ++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/skbuff.h    |   30 +++++++++++++++--
>  net/core/dev.c            |   32 ++++++++++++++++++
>  net/core/skbuff.c         |   79 +++++++++++++++++++++++++++++++++++++++++----
>  4 files changed, 205 insertions(+), 12 deletions(-)
> 

There are too many ifdef's in this implementation.
I would prefer to see a few functions (with stub for the non-ifdef case),
like the network namespace code.
