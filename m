From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] be2net: fix re-loaded PF driver to
 re-gain control of its VFs
Date: Mon, 04 Feb 2013 13:33:29 -0500 (EST)
Message-ID: <20130204.133329.299370683371195718.davem@davemloft.net>
References: <2712f366-e279-42de-9b23-974c8c9b188c@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230Ab3BDSdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:33:32 -0500
In-Reply-To: <2712f366-e279-42de-9b23-974c8c9b188c@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 4 Feb 2013 12:00:11 +0530

> Currently, when the PF driver is unloaded and re-loaded while VFs are attached
> to VMs, it loses control of its VFs.
> 
> The PF driver now uses the newly defined/created GET_IFACE_LIST cmd
> (available in FW ver >= 4.6) to query the if_id of the VFs
> (enabled in its previous life). The PF driver then uses the if_id for
> further VF configuration.
> 
> The GET_IFACE_MAC_LIST cmd has also implemented in BE3 FW for PF to
> query pmac-ids used by its VFs.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
