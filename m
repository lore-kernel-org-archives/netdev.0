From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-mm1 4/4] via-velocity: unneeded forward declarations
Date: Tue, 22 Jun 2004 00:01:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622000111.C9979@electric-eye.fr.zoreil.com>
References: <20040621235615.A7869@electric-eye.fr.zoreil.com> <20040621235808.A9979@electric-eye.fr.zoreil.com> <20040621235946.B9979@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040621235946.B9979@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Jun 21, 2004 at 11:59:46PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Removal of unneeded forward declarations.

diff -puN drivers/net/via-velocity.c~via-velocity-100 drivers/net/via-velocity.c
--- linux-2.6.7/drivers/net/via-velocity.c~via-velocity-100	2004-06-21 22:20:53.000000000 +0200
+++ linux-2.6.7-fr/drivers/net/via-velocity.c	2004-06-21 23:46:19.000000000 +0200
@@ -230,7 +230,6 @@ static int rx_copybreak = 200;
 MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
-static int velocity_found1(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr, struct velocity_info_tbl *info);
 static int velocity_get_pci_info(struct velocity_info *, struct pci_dev *pdev);
 static void velocity_print_info(struct velocity_info *vptr);
@@ -242,10 +241,8 @@ static void velocity_set_multi(struct ne
 static struct net_device_stats *velocity_get_stats(struct net_device *dev);
 static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int velocity_close(struct net_device *dev);
-static int velocity_rx_srv(struct velocity_info *vptr, int status);
 static int velocity_receive_frame(struct velocity_info *, int idx);
 static int velocity_alloc_rx_buf(struct velocity_info *, int idx);
-static void velocity_init_registers(struct velocity_info *vptr, enum velocity_init_type type);
 static void velocity_free_rd_ring(struct velocity_info *vptr);
 static void velocity_free_tx_buf(struct velocity_info *vptr, struct velocity_td_info *);
 static int velocity_soft_reset(struct velocity_info *vptr);
@@ -260,7 +257,6 @@ static int velocity_mii_read(struct mac_
 static int velocity_mii_write(struct mac_regs *, u8 byMiiAddr, u16 data);
 static u32 mii_check_media_mode(struct mac_regs * regs);
 static u32 check_connection_type(struct mac_regs * regs);
-static void velocity_init_cam_filter(struct velocity_info *vptr);
 static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status);
 
 #ifdef CONFIG_PM

_
