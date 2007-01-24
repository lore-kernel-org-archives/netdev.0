From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.20-rc4-mm1: PCI=n: drivers/net/3c59x.c compile error
Date: Wed, 24 Jan 2007 14:53:54 +0100
Message-ID: <20070124135354.GI17836@stusta.de>
References: <20070111222627.66bb75ab.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>,
	Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751468AbXAXNxt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070111222627.66bb75ab.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3x59x-fix-pci-resource-management.patch causes the following compile 
error with CONFIG_PCI=n:

<--  snip  -->

...
  CC      drivers/net/3c59x.o
/home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c: In function 'vortex_init_one':
/home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c:961: error: implicit declaration of function 'pci_request_regions'
/home/bunk/linux/kernel-2.6/linux-2.6.20-rc4-mm1/drivers/net/3c59x.c:985: error: implicit declaration of function 'pci_release_regions'
make[3]: *** [drivers/net/3c59x.o] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
