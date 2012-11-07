From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch 0/2] bnx2x: Enable cnic at run-time
Date: Wed, 07 Nov 2012 18:57:36 -0500 (EST)
Message-ID: <20121107.185736.1387317478385227779.davem@davemloft.net>
References: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab2KGX5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 18:57:37 -0500
In-Reply-To: <1352285148-21784-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Wed, 7 Nov 2012 12:45:46 +0200

> This patch series removes the BCM_CNIC bnx2x define, and eliminates the use of
> the CONFIG_CNIC kconfig option.
> The define removal is mainly important for SR-IOV, as the VF driver will use the
> same code as the PF/hypervisor driver. Since storage is not supported in
> SR-IOV (while is usually enabled in the non SR-IOV driver), we don't want to
> waste resources on it.
> After this change, cnic-related resources are allocated only when the cnic
> module registers with bnx2x (which means that the user asked for storage
> services). Also only at this stage the HW is configured to non-NIC (offload)
> mode.
> The first patch is the driver-FW HSI addition to change the 'update' ramrod for
> offload mode configuration at run-time.
> The second patch is for the removal of the BCM_CNIC define, and for separating
> the load flow to two stages, one for L2 and one for cnic-related stuff.
> 
> Please consider applying this patch series to net-next.

Series applied, thanks.
