From: Mikael Pettersson <mikpe@it.uu.se>
Subject: [2.6.17-rc6] Section mismatch in drivers/net/ne.o during modpost
Date: Sat, 10 Jun 2006 14:11:42 +0200 (MEST)
Message-ID: <200606101211.k5ACBgtl029545@harpo.it.uu.se>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:18565 "EHLO aun.it.uu.se")
	by vger.kernel.org with ESMTP id S1751490AbWFJMLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 08:11:45 -0400
To: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While compiling 2.6.17-rc6 for a 486 with an NE2000 ISA ethernet card, I got:

  Building modules, stage 2.
make -rR -f /tmp/linux-2.6.17-rc6/scripts/Makefile.modpost
  scripts/mod/modpost   -o /tmp/linux-2.6.17-rc6/Module.symvers   vmlinux drivers/net/8390.o drivers/net/ne.o lib/crc32.o net/packet/af_packet.o
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x158) and 'ne_block_input'
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x176) and 'ne_block_input'
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x183) and 'ne_block_input'
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x1ea) and 'ne_block_input'
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.data:isapnp_clone_list from .text between 'init_module' (at offset 0x251) and 'ne_block_input'
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x266) and 'ne_block_input'
WARNING: drivers/net/ne.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x29b) and 'ne_block_input'

Not sure how serious this is; the driver seems to work fine later on.

/Mikael
