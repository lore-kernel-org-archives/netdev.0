From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 14:45:34 -0500
Message-ID: <20070213194534.GB16991@havoc.gtf.org>
References: <1171397612.18944.25.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46228 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbXBMTpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:45:34 -0500
Content-Disposition: inline
In-Reply-To: <1171397612.18944.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 12:13:32PM -0800, Michael Chan wrote:
> [TG3]: Save MSI state before suspend.
> 
> This fixes the following problem:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7969
> 
> The MSI state needs to be saved during suspend.  PCI state saved
> during tg3_init_one() does not contain valid MSI state because
> MSI hasn't been enabled.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I'm curious if, after this patch is applied, all the pci_save_state()
calls are truly necessary?

	Jeff



