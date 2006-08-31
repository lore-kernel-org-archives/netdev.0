From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 00/26] e100, e1000, ixgb updates
Date: Thu, 31 Aug 2006 14:26:30 -0700
Message-ID: <44F75406.2020509@intel.com>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21310 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750968AbWHaV1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 17:27:50 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff,

I have adjusted several things in our queue after comments. Here is a summary 
of those changes against the original summary.

These changes are available through git.

Please pull:
  git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

(against netdev-2.6#upstream 699a71238856b19091503c671bac8abb1e3f9a3a)


Cheers,

Auke



Kok, Auke wrote:
> Vasily Averin <vvs@sw.ru>
>      e1000: IRQ resources cleanup
>      e1000: e1000_probe resources cleanup
>      e1000: ring buffers resources cleanup
> 
> Jesse Brandeburg <jesse.brandeburg@intel.com>
>      e1000: unify WoL capability detection code
all unchanged

>      e1000: Add PCI ID 0x10a4 for our new 4-port PCI-Express device
This patch was not Acked but I assume no objections exist.

>      ixgb: Set a constant blink rate for ixgb adapter identify (1sec on, 1sec off)
unchanged

>      ixgb: Cache-align all TX components of the adapter struct.
modified per comments to include "_in_smp"

>      ixgb: Add buffer_info and test like e1000 has.
unchanged

> Christoph Hellwig <hch@lst.de>
>      e1000: clean up skb allocation code, patch submitted by Christoph
Changed topic as attribution is already in the patch correctly

> Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>      e1000: Deprecate mii-tool SIOCMIIREG ioctl
Dropped patch.

> Auke Kok <auke-jan.h.kok@intel.com>
>      e1000: Whitespace cleanup, cosmetic changes
>      e1000: error out if we cannot enable PCI device on resume
>      e1000: remove unused part_num reading code
>      e1000: Use module param array code
>      e1000: Increment driver version to 7.2.7-k2
>      e100: Convert e100 to use netdev_alloc_skb().
all unchanged

>      e100: reduce time under spinlock
Dropped patch.

>      e100: remove skb->dev assignment
>      e100: increment version to 3.5.16-k2
>      ixgb: Convert dev_alloc_skb to netdev_alloc_skb.
>      ixgb: convert dev->priv to netdev_priv(dev).
>      ixgb: recalculate after how many descriptors to wake the queue
>      ixgb: remove skb->dev assignment
>      ixgb: Increment version to 1.0.112-k2
> 
> Linas Vepstas <linas@austin.ibm.com>
>      e100: fix error recovery
>      ixgb: Add PCI Error recovery callbacks
all unchanged

Cheers,

Auke

---
  drivers/net/e100.c                |    8
  drivers/net/e1000/e1000.h         |    6
  drivers/net/e1000/e1000_ethtool.c |  219 ++++---
  drivers/net/e1000/e1000_hw.c      | 1059 ++++++++++++++++++-------------------
  drivers/net/e1000/e1000_hw.h      |   26
  drivers/net/e1000/e1000_main.c    |  145 +++--
  drivers/net/e1000/e1000_param.c   |  161 +++--
  drivers/net/ixgb/ixgb.h           |    5
  drivers/net/ixgb/ixgb_ethtool.c   |    6
  drivers/net/ixgb/ixgb_main.c      |  140 ++++-
  10 files changed, 979 insertions(+), 796 deletions(-)
