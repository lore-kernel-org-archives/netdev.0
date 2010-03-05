From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: fix packet corruption and tx hang during NFSv2
Date: Fri, 05 Mar 2010 14:01:58 -0800 (PST)
Message-ID: <20100305.140158.168568771.davem@davemloft.net>
References: <20100305122131.8250.21132.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, nhorman@tuxdriver.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756105Ab0CEWBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 17:01:39 -0500
In-Reply-To: <20100305122131.8250.21132.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 05 Mar 2010 04:21:44 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> when receiving a particular type of NFS v2 UDP traffic, the hardware could
> DMA some bad data and then hang, possibly corrupting memory.
> 
> Disable the NFS parsing in this hardware, verified to fix the bug.
> 
> Originally reported and reproduced by RedHat's Neil Horman
> CC: nhorman@tuxdriver.com
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
