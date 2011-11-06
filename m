From: Alexander Kolesen <kolesen.a@gmail.com>
Subject: ixgbe: compilation failed if CONFIG_PCI_IOV isn't set
Date: Sun, 6 Nov 2011 03:08:19 +0300
Message-ID: <20111106000819.GC12157@vaio>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Rose <gregory.v.rose@intel.com>,
	Sibai Li <sibai.li@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.wargaming.net ([213.252.131.228]:35323 "EHLO
	mail.wargaming.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab1KFASE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2011 20:18:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.
I've tried to build vanilla kernel (HEAD: 5c8a0fbb) and got the error:

  CC [M]  drivers/net/ethernet/intel/ixgbe/ixgbe_main.o
  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_set_interrupt_capability':
  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:4724:3: error: implicit declaration of function 'ixgbe_disable_sriov'
  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_remove':
  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7773:3: error: implicit declaration of function 'ixgbe_check_vf_assignment'
  make[5]: *** [drivers/net/ethernet/intel/ixgbe/ixgbe_main.o] Error 1
  make[4]: *** [drivers/net/ethernet/intel/ixgbe] Error 2
  make[3]: *** [drivers/net/ethernet/intel] Error 2
  make[2]: *** [drivers/net/ethernet] Error 2
  make[1]: *** [drivers/net] Error 2
  make: *** [drivers] Error 2

Looks like the commit 9487dc84 breaks it when the CONFIG_PCI_IOV switched off.
