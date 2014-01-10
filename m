From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-next] intel ethernet: fix s390 build failure due to
 implicit prefetch.h
Date: Fri, 10 Jan 2014 14:52:29 -0500 (EST)
Message-ID: <20140110.145229.334617909103085999.davem@davemloft.net>
References: <1389382096-17122-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, mitch.a.williams@intel.com,
	gregory.v.rose@intel.com, sibai.li@intel.com,
	jeffrey.t.kirsher@intel.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbaAJTwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:52:31 -0500
In-Reply-To: <1389382096-17122-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 10 Jan 2014 14:28:16 -0500

> As of commit 7f12ad741a4870b8b6e3aafbcd868d0191770802 ("i40evf: transmit
> and receive functionality") the s390 builds (allyesconfig) fail with:
> 
> drivers/net/ethernet/intel/i40evf/i40e_txrx.c: In function 'i40e_clean_rx_irq':
> drivers/net/ethernet/intel/i40evf/i40e_txrx.c:818:3: error: implicit declaration of function 'prefetch'
> make[5]: *** [drivers/net/ethernet/intel/i40evf/i40e_txrx.o] Error 1
> 
> due to an implicit assumption that the prototype from linux/prefetch.h
> will be present.
> 
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Sibai Li <sibai.li@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

I hope the Intel folks will pick this up quickly and push it to me.
