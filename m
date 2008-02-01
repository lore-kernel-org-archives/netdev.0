From: Sam Ravnborg <sam@ravnborg.org>
Subject: netdev share of section mismatch warnings...
Date: Fri, 1 Feb 2008 14:58:46 +0100
Message-ID: <20080201135846.GB13524@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:57146 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755734AbYBAN6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 08:58:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can we please get the following warnings fixed
in mainline soonish.

I get the below list with a x86 64bit allyesconfig build
and I expect anyone to see roughly the same list.

It would be great to say that both net/ and drivers/net/
were warning free in this respect.

If you have questions let me know and I will try to help out.

	Sam

WARNING: drivers/net/built-in.o(.text+0x42e93): Section mismatch in reference from the function t3_io_slot_reset() to the function .devinit.text:t3_prep_adapter()
The function  t3_io_slot_reset() references
the function __devinit t3_prep_adapter().
This is often because t3_io_slot_reset lacks a __devinit
annotation or the annotation of t3_prep_adapter is wrong.

WARNING: drivers/net/built-in.o(.text+0x89927): Section mismatch in reference from the function sis190_get_mac_addr() to the function .devinit.text:sis190_get_mac_addr_from_apc()
The function  sis190_get_mac_addr() references
the function __devinit sis190_get_mac_addr_from_apc().
This is often because sis190_get_mac_addr lacks a __devinit
annotation or the annotation of sis190_get_mac_addr_from_apc is wrong.

WARNING: drivers/net/built-in.o(.text+0x89934): Section mismatch in reference from the function sis190_get_mac_addr() to the function .devinit.text:sis190_get_mac_addr_from_eeprom()
The function  sis190_get_mac_addr() references
the function __devinit sis190_get_mac_addr_from_eeprom().
This is often because sis190_get_mac_addr lacks a __devinit
annotation or the annotation of sis190_get_mac_addr_from_eeprom is wrong.

WARNING: drivers/net/built-in.o(.text+0x14866b): Section mismatch in reference from the function mlx4_init_icm() to the function .devinit.text:mlx4_init_cmpt_table()
The function  mlx4_init_icm() references
the function __devinit mlx4_init_cmpt_table().
This is often because mlx4_init_icm lacks a __devinit
annotation or the annotation of mlx4_init_cmpt_table is wrong.

WARNING: drivers/net/built-in.o(.text+0x148c19): Section mismatch in reference from the function mlx4_init_hca() to the function .devinit.text:mlx4_load_fw()
The function  mlx4_init_hca() references
the function __devinit mlx4_load_fw().
This is often because mlx4_init_hca lacks a __devinit
annotation or the annotation of mlx4_load_fw is wrong.

WARNING: drivers/net/built-in.o(.text+0x1494bd): Section mismatch in reference from the function __mlx4_init_one() to the function .devinit.text:mlx4_enable_msi_x()
The function  __mlx4_init_one() references
the function __devinit mlx4_enable_msi_x().
This is often because __mlx4_init_one lacks a __devinit
annotation or the annotation of mlx4_enable_msi_x is wrong.

WARNING: drivers/net/built-in.o(.text+0x14a77e): Section mismatch in reference from the function mlx4_init_mr_table() to the function .devinit.text:mlx4_buddy_init()
The function  mlx4_init_mr_table() references
the function __devinit mlx4_buddy_init().
This is often because mlx4_init_mr_table lacks a __devinit
annotation or the annotation of mlx4_buddy_init is wrong.

WARNING: drivers/net/built-in.o(.text+0x1500a1): Section mismatch in reference from the function olympic_open() to the function .devinit.text:olympic_init()
The function  olympic_open() references
the function __devinit olympic_init().
This is often because olympic_open lacks a __devinit
annotation or the annotation of olympic_init is wrong.

WARNING: drivers/net/built-in.o(.data+0x54478): Section mismatch in reference from the variable ath5k_pci_drv_id to the variable .devinit.data:ath5k_pci_id_table
The variable ath5k_pci_drv_id references
the variable __devinitdata ath5k_pci_id_table
If the reference is valid then annotate the
variable with __init* (see linux/init.h) or name the variable:
*driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

WARNING: drivers/net/built-in.o(.data+0x54480): Section mismatch in reference from the variable ath5k_pci_drv_id to the function .devinit.text:ath5k_pci_probe()
The variable ath5k_pci_drv_id references
the function __devinit ath5k_pci_probe()
If the reference is valid then annotate the
variable with __init* (see linux/init.h) or name the variable:
*driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

WARNING: drivers/net/built-in.o(.data+0x54488): Section mismatch in reference from the variable ath5k_pci_drv_id to the function .devexit.text:ath5k_pci_remove()
The variable ath5k_pci_drv_id references
the function __devexit ath5k_pci_remove()
If the reference is valid then annotate the
variable with __exit* (see linux/init.h) or name the variable:
*driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

