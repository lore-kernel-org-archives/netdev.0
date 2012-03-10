From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/8] Pull request for 'davem-next.r8169' branch
Date: Sat, 10 Mar 2012 23:17:51 +0100
Message-ID: <20120310221751.GA9692@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41067 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752673Ab2CJWTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 17:19:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

This patchset tidies up the dependencies within the driver. I have not
merged the patches to avoid confusing diff.

I have a patchkit similar to the last patch in the series ("r8169: stop
using net_device.{base_addr, irq}.") for some PCI only drivers. Depending
on the driver, it contains either a few lines of changes (~20 drivers) or
a complete conversion to __iomem + pci_iomap (4~6 drivers). Would it be
appropriate to send a patch per driver for the latter and only a single
patch for the former ?

Distance from 'base' (b2d3298e0916fa059712691c85a0e97becc4ab9f)
---------------------------------------------------------------

92a7c4e7183bcd29e2366f1ee784ad395c291134
31fa8b1855cb1f1fd99e2f2f9b8f2c8f113e9f2e
dc1c00ce70da5d3bb3fc97707e04f598ff72e7ba
df43ac7831a0e321b6b183b7eb48ae4577207453
e6b763ea0527f1038752a591e4b45cffacc4bba2
fa9c385ef57c1a04966f01314f96fb7c9347d924
3b6cf25de260d5607fa1fe48ba1af0f6d057708e
e27566ed370da09e3b812d3d76dce002915a5bdd

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c | 1966 +++++++++++++++++-----------------
 1 files changed, 971 insertions(+), 995 deletions(-)

Shortlog
--------

Francois Romieu (8):
      r8169: move the driver removal method to the end of the driver file.
      r8169: move the driver probe method to the end of the driver file.
      r8169: move net_device_ops beyond the methods it references.
      r8169: move rtl_set_rx_mode before its rtl_hw_start callers.
      r8169: move rtl8169_open after rtl_task it depends on.
      r8169: move the netpoll handler after the irq handler.
      r8169: move rtl_cfg_info closer to its caller.
      r8169: stop using net_device.{base_addr, irq}.

-- 
Ueimor
