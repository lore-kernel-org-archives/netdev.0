From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/9] e100: disable interrupts at boot
Date: Thu, 27 Apr 2006 06:00:08 -0400
Message-ID: <44509628.4090704@garzik.org>
References: <200604270932.k3R9WBhr025327@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn.helgaas@hp.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, nils.rennebarth@packetalarm.com,
	stern@rowland.harvard.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:17573 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965054AbWD0KAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 06:00:12 -0400
To: akpm@osdl.org
In-Reply-To: <200604270932.k3R9WBhr025327@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
> Apparently the Intel PRO/100 device enables interrupts on reset.  Unless
> firmware explicitly disables PRO/100 interrupts, we can get a flood of
> interrupts when a driver attaches to an unrelated device that happens to
> share the PRO/100 IRQ.
> 
> This should resolve this "irq 11: nobody cared" bug report:
>     http://bugzilla.kernel.org/show_bug.cgi?id=5918
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: <stern@rowland.harvard.edu>
> Cc: <nils.rennebarth@packetalarm.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

I'm really worried that we are burdening the kernel for a very very rare 
condition.  Do we want to apply this for one stupid firmware?

Can't early userspace just run setpci to fix this one?

	Jeff



