From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] sfc: Enabling EF10 Vf's, set up
 vswitching and bind the SFC driver to the VF's
Date: Sat, 09 May 2015 16:18:10 -0400 (EDT)
Message-ID: <20150509.161810.1475575394219926340.davem@davemloft.net>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbbEIUSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:18:12 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 6 May 2015 00:53:03 +0100

> This set of patches makes way for the implementation of EF10
> SR-IOV driver starting with some cleanup code.
> NIC specific SR-IOV functions are moved to their own header
> and netdev_ops are made generic instead of being NIC specific
> 
> Next in line comes the patch to enable VF's using sriov_configure.
> VEB vswitching hierarchy is set up next followed by patches to
> prepare sfc driver to bind to enabled VF's
> 
> This is followed by patch to support use of shared RSS contexts
> which makes VF's use shared RSS contexts in all cases.
> 
> Patch series ends with a patch to bind the sfc driver to the
> enabled VF's which creates network interfaces corresponding to
> the VF's.
> 
> Coming up soon are the patches to set_vf_mac, set_vf_config,
> set_vf_vlan, vf_spoofcheck, etc.
> 
> These patches have been tested with and without CONFIG_SFC_SRIOV.
> In the case of CONFIG_SFC_SRIOV=y enabling of VF's using
> sriov_configure is also tested. The enabled VF's bind to the
> installed sfc driver succesfully to create network interfaces.
> In the case of CONFIG_SFC_SRIOV=n enabling of VF's using
> sriov_configure returns the correct error message:
> "Function not implemented".

Series applied, thanks.
