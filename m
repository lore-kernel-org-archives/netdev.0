From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2 v4] ibmvnic: map L2/L3/L4 header
 descriptors to firmware
Date: Tue, 05 Apr 2016 19:51:57 -0400 (EDT)
Message-ID: <20160405.195157.2030686647042617056.davem@davemloft.net>
References: <1459549235-22039-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760275AbcDEXwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:52:00 -0400
In-Reply-To: <1459549235-22039-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Fri,  1 Apr 2016 17:20:34 -0500

> Allow the VNIC driver to provide descriptors containing
> L2/L3/L4 headers to firmware.  This feature is needed
> for greater hardware compatibility and enablement of checksum
> and TCP offloading features.
> 
> A new function is included for the hypervisor call,
> H_SEND_SUBCRQ_INDIRECT, allowing a DMA-mapped array of SCRQ
> descriptor elements to be sent to the VNIC server.
> 
> These additions will help fully enable checksum offloading as
> well as other features as they are included later.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
