From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [patch 4/6] [TULIP]  Quiet down tulip_stop_rxtx
Date: Thu, 15 Mar 2007 17:10:10 -0700
Message-ID: <20070316001010.GE5291@nifty>
References: <20070312093128.577087000@linux.intel.com> <20070312184218.317747000@linux.intel.com> <45F96556.10205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:17939 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753436AbXCPAKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 20:10:06 -0400
Content-Disposition: inline
In-Reply-To: <45F96556.10205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 11:25:10AM -0400, Jeff Garzik wrote:
> 
> Here's the problem with this:  this printk is signalling that the DMA 
> engines have not yet stopped, which is an event of which we should be wary.
> 
> While it makes sense to do this patch, since the complaining cards 
> appear to work anyway, we also need to take into account the times when 
> this is not a spurious warning.
> 
> Thus, I would consider maybe adding a warning somewhere in the 
> DMA-engine-start region of code, that complains if the DMA engines are 
> already active, or somesuch.

Yeah, I agree it's signifying a problem, and we should have a warning
(only one) until we figure out what's going on.  Put on my to-do list.

-VAL
