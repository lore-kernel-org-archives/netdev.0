From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: build failure on ixgbe
Date: Sun, 6 Nov 2011 10:32:21 +0200
Message-ID: <4EB64615.1080807@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Greg Rose <gregory.v.rose@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:41579 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750855Ab1KFIek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 03:34:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9487dc844054e1fc691fb82f4e19da337e2ca35e "ixgbe: Fix compiler 
warnings" wrapped
the definitions of the below two function with ifdef CONFIG_PCI_IOV but 
not all their
usages, once that commit is removed, I can build the code okay

Or.

>  linux-2.6.ko.git]# make
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   CALL    scripts/checksyscalls.sh
>   CHK     include/generated/compile.h
>   CC [M]  drivers/net/ethernet/intel/ixgbe/ixgbe_main.o
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 
> ixgbe_set_interrupt_capability:
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:4724: error: implicit 
> declaration of function ixgbe_disable_sriov
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function ixgbe_remove:
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7773: error: implicit 
> declaration of function ixgbe_check_vf_assignment
> make[5]: *** [drivers/net/ethernet/intel/ixgbe/ixgbe_main.o] Error 1
> make[4]: *** [drivers/net/ethernet/intel/ixgbe] Error 2
> make[3]: *** [drivers/net/ethernet/intel] Error 2
> make[2]: *** [drivers/net/ethernet] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
