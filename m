From: Andrew Morton <akpm@linux-foundation.org>
Subject: i386 allmodconfig, current mainline
Date: Mon, 9 Aug 2010 16:43:46 -0700
Message-ID: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, x86@kernel.org,
	linux-rdma@vger.kernel.org
To: Greg KH <greg@kroah.com>, David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Guys.  What's goin' on out there?


drivers/power/olpc_battery.c:387: error: unknown field 'owner' specified in initializer
drivers/power/olpc_battery.c:387: warning: initialization from incompatible pointer type
make[2]: *** [drivers/power/olpc_battery.o] Error 1
make[1]: *** [drivers/power] Error 2


drivers/mtd/maps/gpio-addr-flash.c: In function 'gpio_flash_probe':
drivers/mtd/maps/gpio-addr-flash.c:212: warning: cast to pointer from integer of different size
drivers/mtd/maps/gpio-addr-flash.c:224: warning: cast to pointer from integer of different size


drivers/pci/intel-iommu.c: In function 'dma_pte_addr':
drivers/pci/intel-iommu.c:239: warning: passing argument 1 of '__cmpxchg64' from incompatible pointer type


drivers/net/wan/farsync.c: In function 'fst_intr_rx':
drivers/net/wan/farsync.c:1312: warning: cast to pointer from integer of different size
drivers/net/wan/farsync.c: In function 'do_bottom_half_tx':
drivers/net/wan/farsync.c:1407: warning: cast to pointer from integer of different size


fs/squashfs/xattr.c:37: warning: 'squashfs_xattr_handler' declared inline after being called
fs/squashfs/xattr.c:37: warning: previous declaration of 'squashfs_xattr_handler' was here


drivers/net/wireless/ipw2x00/ipw2100.c: In function 'ipw2100_tx_send_commands':
drivers/net/wireless/ipw2x00/ipw2100.c:3063: warning: cast to pointer from integer of different size


In file included from drivers/platform/x86/intel_scu_ipc.c:26:
/usr/src/devel/arch/x86/include/asm/mrst.h:14: warning: 'struct sfi_table_header' declared inside parameter list
/usr/src/devel/arch/x86/include/asm/mrst.h:14: warning: its scope is only this definition or declaration, which is probably not what you want


drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_alloc_fast_reg_page_list':
drivers/infiniband/hw/nes/nes_verbs.c:477: warning: cast to pointer from integer of different size
drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_post_send':
drivers/infiniband/hw/nes/nes_verbs.c:3486: warning: cast to pointer from integer of different size
drivers/infiniband/hw/nes/nes_verbs.c:3486: warning: cast to pointer from integer of different size


drivers/infiniband/hw/cxgb4/cq.c: In function 'destroy_cq':
drivers/infiniband/hw/cxgb4/cq.c:58: warning: cast from pointer to integer of different size
drivers/infiniband/hw/cxgb4/cq.c: In function 'create_cq':
drivers/infiniband/hw/cxgb4/cq.c:135: warning: cast from pointer to integer of different size


drivers/dma/timb_dma.c: In function 'td_fill_desc':
drivers/dma/timb_dma.c:203: warning: cast to pointer from integer of different size


drivers/net/wireless/iwmc3200wifi/rx.c: In function 'iwm_ntf_wifi_if_wrapper':
drivers/net/wireless/iwmc3200wifi/rx.c:1198: warning: comparison is always true due to limited range of data type
