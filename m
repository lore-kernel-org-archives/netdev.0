From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] sfc: Nic specific sriov functions,
 netdev_ops and sriov_configure
Date: Sun, 12 Apr 2015 20:35:29 -0400 (EDT)
Message-ID: <20150412.203529.2279251465380502525.davem@davemloft.net>
References: <5527926E.7030903@solarflare.com>
	<20150412.203002.454810061015500201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48040 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbDMAfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 20:35:31 -0400
In-Reply-To: <20150412.203002.454810061015500201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 12 Apr 2015 20:30:02 -0400 (EDT)

> From: Shradha Shah <sshah@solarflare.com>
> Date: Fri, 10 Apr 2015 10:05:50 +0100
> 
>> First two patches among the series of patches to support SRIOV on EF10.
>> 
>> First patch declares nic specific sriov functions in nic specific headers,
>> creates only one instance of the netdev_ops, removes sriov functionality
>> from Falcon code.
>> 
>> Second patch adds support for sriov_configure.
>> 
>> The Virtual Functions can be enabled but they do not bind to the SFC
>> driver just yet.
> 
> Series applied.

Reverted, are you even testing this with SFC_SRIOV disabled at all?

Kernel: arch/x86/boot/bzImage is ready  (#26)
ERROR: "efx_siena_sriov_probe" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_init" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_mac_address_changed" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_wanted" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_set_vf_mac" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_init_sriov" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_ef10_sriov_configure" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_tx_flush_done" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_fini_sriov" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_flr" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_get_vf_config" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_reset" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_rx_flush_done" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_event" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_configure" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_desc_fetch_err" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_fini" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_set_vf_vlan" [drivers/net/ethernet/sfc/sfc.ko] undefined!
ERROR: "efx_siena_sriov_set_vf_spoofchk" [drivers/net/ethernet/sfc/sfc.ko] undefined!
scripts/Makefile.modpost:90: recipe for target '__modpost' failed
