From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 0/7] 2.6.5-bk-netdev - r8169 queue
Date: Mon, 5 Apr 2004 23:55:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405235545.A20805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

No ack for previous patches. Try #2.

The following serie of patches applies against 2.6.5 + bk-netdev (as found
in 2.6.5-mm1 for instance). It contains:

- r8169-dma-api-resync.patch
  resync with the recent DMA api changes (pci_dma_sync_single_for_{cpu/device})

- r8169-ethtool-introduction.patch
  lightweight ethtool support

- r8169-missing-static.patch
  missing 'static' qualifiers

- r8169-barrier.patch
  safety rmb()

- r8169-kill-potential-busy-loop.patch
  A similar patch exists in -mm. I like mine better.

- r8169-dac-00.patch
  DMA_{32/64}_BIT_MASK thing against include/linux/dma-mapping.h

- r8169-dac-10.patch
  DAC changes for (as of now even more) happy owners of x86-64.
  It seems to work.

An update of the patch against 2.6.5 is available for testers at:
http://www.fr.zoreil.com/people/francois/misc/20040405-2.6.5-r8169.c-stable.patch

The link loss issue when cable is unplugged is on the TODO.

--
Ueimor
