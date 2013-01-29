From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000e: enable ECC on I217/I218 to catch packet buffer
 memory errors
Date: Tue, 29 Jan 2013 16:01:49 -0500 (EST)
Message-ID: <20130129.160149.1063934767478304765.davem@davemloft.net>
References: <1359369828-13663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab3A2VBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 16:01:51 -0500
In-Reply-To: <1359369828-13663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 28 Jan 2013 02:43:48 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> In rare instances, memory errors have been detected in the internal packet
> buffer memory on I217/I218 when stressed under certain environmental
> conditions.  Enable Error Correcting Code (ECC) in hardware to catch both
> correctable and uncorrectable errors.  Correctable errors will be handled
> by the hardware.  Uncorrectable errors in the packet buffer will cause the
> packet to be received with an error indication in the buffer descriptor
> causing the packet to be discarded.  If the uncorrectable error is in the
> descriptor itself, the hardware will stop and interrupt the driver
> indicating the error.  The driver will then reset the hardware in order to
> clear the error and restart.
> 
> Both types of errors will be accounted for in statistics counters.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Cc: <stable@vger.kernel.org> # 3.5.x & 3.6.x
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Applied.
