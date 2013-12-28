From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 03/16] i40e: Populate and check pci bus speed and
 width
Date: Sat, 28 Dec 2013 01:10:19 -0500 (EST)
Message-ID: <20131228.011019.2092452962918918748.davem@davemloft.net>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388200940-9113-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catherine.sullivan@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764Ab3L1GKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:10:21 -0500
In-Reply-To: <1388200940-9113-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Dec 2013 19:22:07 -0800

> From: Catherine Sullivan <catherine.sullivan@intel.com>
> 
> Call i40e_set_pci_config_data from probe, then check that
> we are in a 8GT/s x8 PCIe slot and send a warning if we are not.
> 
> Change-Id: I62815c574cee50d2787c50bbe956dde7a7a75a11
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Please use the available PCI_EXP_LNKSTA_* defines already available in
linux/pci_regs.h, expanding them if necessary.

Thanks.
