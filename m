From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: i40e: avoid unused function warnings
Date: Wed, 20 Jan 2016 23:54:46 +0100
Message-ID: <6894276.2dlRmisKUo@wuerfel>
References: <2806620.EpZqDlZTO3@wuerfel> <8814508.SjLecHrQqA@wuerfel> <1453329885.2958.32.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	davem@davemloft.net
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453329885.2958.32.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 20 January 2016 14:44:45 Jeff Kirsher wrote:
> Yeah, I have a fix for that as well.
> 
> You can confirm by pulling my next-queue tree (dev-queue branch).
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git d
> ev-queue
> 

I checked out that branch, but still see both warnings in that one, plus
a new build error in igb, which I don't see in linux-next:

drivers/net/ethernet/intel/igb/igb_cdev.c: In function 'igb_mapring':
drivers/net/ethernet/intel/igb/igb_cdev.c:150:2: error: implicit declaration of function 'set_pages_uc' [-Werror=implicit-function-declaration]
  set_pages_uc(virt_to_page(ring->desc), ring->size >> PAGE_SHIFT);
  ^
drivers/net/ethernet/intel/igb/igb_cdev.c: In function 'igb_unmapring':
drivers/net/ethernet/intel/igb/igb_cdev.c:275:2: error: implicit declaration of function 'set_pages_wb' [-Werror=implicit-function-declaration]
  set_pages_wb(virt_to_page(ring->desc), ring->size >> PAGE_SHIFT);

	Arnd
