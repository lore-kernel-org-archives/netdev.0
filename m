From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: fix possible null buffer error
Date: Wed, 21 Sep 2011 02:16:09 -0400 (EDT)
Message-ID: <20110921.021609.1547370353809586562.davem@davemloft.net>
References: <1316567583-28673-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab1IUGSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 02:18:17 -0400
In-Reply-To: <1316567583-28673-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 20 Sep 2011 18:13:03 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> It seems that at least one PPC machine would occasionally give a (valid) 0 as
> the return value from dma_map, this caused the ixgbe code to not work
> correctly.  A fix is pending in the PPC tree to not return 0 from dma map, but
> we can also fix the driver to make sure we don't mess up in other arches as
> well.
> 
> This patch is applicable to all current stable kernels.
> 
> Ref: https://bugzilla.redhat.com/show_bug.cgi?id=683611
> 
> Reported-by: Neil Horman <nhorman@redhat.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Alexander Duyck <alexander.h.duyck@intel.com>
> CC: stable@kernel.org
> Tested-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
