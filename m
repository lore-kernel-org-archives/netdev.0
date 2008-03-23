From: Vlastislav SUCHARDA <vsucharda@aplis.cz>
Subject: Realtek source
Date: Mon, 24 Mar 2008 00:00:45 +0100
Message-ID: <20080323230045.GA16510@vsuchard.aplis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from warp.aplis.cz ([195.146.105.162]:1519 "EHLO warp.aplis.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756313AbYCWXcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 19:32:32 -0400
Received: from mail.aplis.com (mail.aplis.com [172.16.201.100])
	by warp.aplis.cz (Postfix) with ESMTP id 2DDEF7DD9
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 00:00:46 +0100 (CET)
Received: from mail.aplis.com (localhost [127.0.0.1])
	by mail.aplis.com (Postfix) with ESMTP id 02BD39DD0F
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 00:00:46 +0100 (CET)
Received: from vsuchard.aplis.com (vsuchard.aplis.com [172.16.201.24])
	by mail.aplis.com (Postfix) with ESMTP id DB84F9DD04
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2008 00:00:45 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello authors,

how can I get the source for this specific version of module:

filename:       /lib/modules/2.6.20-1.2962.fc6/kernel/drivers/net/r8169.ko
version:        2.2LK-NAPI
license:        GPL
description:    RealTek RTL-8169 Gigabit Ethernet driver
author:         Realtek and the Linux r8169 crew <netdev@vger.kernel.org>
srcversion:     7E2DE85D6E659F77A6DBCA2
alias:          pci:v00001737d00001032sv*sd00000024bc*sc*i*
alias:          pci:v000016ECd00000116sv*sd*bc*sc*i*
alias:          pci:v00001259d0000C107sv*sd*bc*sc*i*
alias:          pci:v00001186d00004300sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008169sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008168sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008167sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008136sv*sd*bc*sc*i*
alias:          pci:v000010ECd00008129sv*sd*bc*sc*i*
depends:        
vermagic:       2.6.20-1.2962.fc6 SMP mod_unload 
parm:           media:force phy operation. Deprecated by ethtool (8). (array of int)
parm:           rx_copybreak:Copy breakpoint for copy-only-tiny-frames (int)
parm:           use_dac:Enable PCI DAC. Unsafe on 32 bit PCI slot. (int)
parm:           debug:Debug verbosity level (0=none, ..., 16=all) (int)

That is only version which works well with my pci:v000010ECd00008168sv on my laptop,
I need to port on Centos 5.1 latest kernel 2.6.18.
My problem is that Rx (copying in) is super, Tx (copying out) is freezing.

Thank you in advance,

-- 
Vlastislav SUCHARDA
System Support
