From: jes@trained-monkey.org (Jes Sorensen)
Subject: Re: [patch 04/11] drivers/net/acenic.c Removal of old code
Date: Tue, 26 Sep 2006 01:52:37 -0400
Message-ID: <17688.49189.283673.335085@jaguar.mkp.net>
References: <200609252339.k8PNdJ4x002631@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	michal.k.k.piotrowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaguar.mkp.net ([192.139.46.146]:44746 "EHLO jaguar.mkp.net")
	by vger.kernel.org with ESMTP id S1751285AbWIZFwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 01:52:38 -0400
To: akpm@osdl.org
In-Reply-To: <200609252339.k8PNdJ4x002631@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "akpm" == akpm  <akpm@osdl.org> writes:

akpm> From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
akpm> Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
akpm> Cc: Jeff Garzik <jeff@garzik.org>
akpm> Cc: Jes Sorensen <jes@trained-monkey.org>
akpm> Signed-off-by: Andrew Morton <akpm@osdl.org>

Signed-off-by: Jes Sorensen <jes@trained-monkey.org>

akpm>  drivers/net/acenic.c | 4 ---- 1 file changed, 4 deletions(-)

akpm> diff -puN
akpm> drivers/net/acenic.c~drivers-net-acenicc-removal-of-old-code
akpm> drivers/net/acenic.c ---
akpm> a/drivers/net/acenic.c~drivers-net-acenicc-removal-of-old-code +++
akpm> a/drivers/net/acenic.c @@ -163,11 +163,7 @@
akpm> MODULE_DEVICE_TABLE(pci, acenic_pci_tbl) #define
akpm> SET_NETDEV_DEV(net, pdev) do{} while(0) #endif
 
akpm> -#if LINUX_VERSION_CODE >= 0x2051c #define ace_sync_irq(irq)
akpm> synchronize_irq(irq) -#else -#define ace_sync_irq(irq)
akpm> synchronize_irq() -#endif
 
akpm>  #ifndef offset_in_page #define offset_in_page(ptr) ((unsigned
akpm> long)(ptr) & ~PAGE_MASK) _
