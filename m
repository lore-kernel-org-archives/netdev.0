From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 2/2] net: remove print_mac as it's not anymore used
Date: Thu, 17 Sep 2009 08:02:23 +0200
Message-ID: <20090917060223.GB29905@game.jcrosoft.org>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
 <1253146059-4169-2-git-send-email-plagnioj@jcrosoft.com>
 <20090916.205159.191998627.davem@davemloft.net>
 <20090916.205417.253183573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:35856 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753891AbZIQGPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 02:15:14 -0400
Content-Disposition: inline
In-Reply-To: <20090916.205417.253183573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20:54 Wed 16 Sep     , David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 16 Sep 2009 20:51:59 -0700 (PDT)
> 
> > From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > Date: Thu, 17 Sep 2009 02:07:39 +0200
> > 
> >> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > 
> > Applied.
> 
> Actually I had to revert.  It's still used by the FCOE stack in
> the scsi layer.
> 
> Did you actually run grep on the entire tree to see if it's still used
> anywhere or did you only check drivers/net/ and net/ or something
> equally lazy?
I've download the next tree
and noone use use it anymore except the wl12xx which I'll fix
If you can point me in while file or tree I can fous the remaining code I'll
fix it

arch/m68k/kernel/head.S:mmu_print_machine_cpu_types:
arch/m68k/kernel/head.S:        jbsr    mmu_print_machine_cpu_types
drivers/infiniband/hw/amso1100/c2.c:static void c2_print_macaddr(struct net_device *netdev)
drivers/infiniband/hw/amso1100/c2.c:            c2_print_macaddr(netdev);
drivers/infiniband/hw/amso1100/c2.c:    c2_print_macaddr(netdev);
drivers/infiniband/hw/nes/nes.c: * nes_print_macaddr
drivers/infiniband/hw/nes/nes.c:static void nes_print_macaddr(struct net_device *netdev)
drivers/infiniband/hw/nes/nes.c:                nes_print_macaddr(netdev);
drivers/net/r8169.c:static void rtl8169_print_mac_version(struct rtl8169_private *tp)
drivers/net/r8169.c:    rtl8169_print_mac_version(tp);
drivers/net/r8169.c:    rtl8169_print_mac_version(tp);
drivers/net/wireless/wl12xx/wl1271_main.c:                   print_mac(mac, conf->bssid));
drivers/net/wireless/zd1211rw/zd_chip.c:static int scnprint_mac_oui(struct zd_chip *chip, char *buffer, size_t size)
drivers/net/wireless/zd1211rw/zd_chip.c:        i += scnprint_mac_oui(chip, buffer+i, size-i);
include/linux/if_ether.h:extern char *print_mac(char *buf, const unsigned char *addr) __deprecated;
net/ethernet/eth.c:char *print_mac(char *buf, const unsigned char *addr)
net/ethernet/eth.c:EXPORT_SYMBOL(print_mac);

Best Regards,
J.
