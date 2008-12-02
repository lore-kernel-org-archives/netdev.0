From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and private
 channels
Date: Tue, 02 Dec 2008 18:26:49 +0100
Message-ID: <49356FD9.5000509@atmel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com> <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com> <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755923AbYLBR1W@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guennadi Liakhovetski :
> Another problem I encountered with my framebuffer is the initialisation 
> order. You initialise dmaengine per subsys_initcall(), whereas the only 
> way to guarantee the order:
> 
> dmaengine
> dma-device driver
> framebuffer
> 
> when they are all linked into the kernel was to switch dmaengine to 
> arch_initcall, put the dma driver under subsys_initcall, and the 
> framebuffer under a normal module_init / device_initcall.

I did not dig much in this but I feel also that dmaengine is initialized 
a bit late : it seems to be initialized after atmel-mci is started.
It works but it seems to me that dmaengine has to be initialized very 
early...

...my 2 cents.

Regards,
-- 
Nicolas Ferre
