From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] dma-mapping.h
Date: Fri, 2 Mar 2007 16:57:23 -0800
Message-ID: <20070302165723.9eb5ccd1.akpm@linux-foundation.org>
References: <1171651858.16919.14.camel@dhcp-10-7-81-58.broadcom.com>
	<45E8C4B6.4050302@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:50323 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992810AbXCCA53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 19:57:29 -0500
In-Reply-To: <45E8C4B6.4050302@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Mar 2007 19:43:34 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> Gary Zambrano wrote:
> > Added dma_sync_single_range_for_cpu/device to dma-mapping.h in asm-arm &
> > asm-avr32 to call dma_sync_single_for_cpu/device. This patch enables b44
> > to compile on systems with these cpus.
> > This patch was created with the assumption that another method of
> > dma_sync_single_range_for_cpu/device does not exist on these
> > architectures.
> > 
> > 
> > Signed-off by: Gary Zambrano <zambrano@broadcom.com>
> 
> this patch looks OK to me, but I'm not the one to apply it.  This should 
> go through Andrew or linux-arch
> 

yeah, I split this into separate arm and avr32 patches and queued them up a while
back.  I need to send them off to Russell and Haavard.  But I'm a bit sluggish
about forwarding things to the subsystem maintainers.  Perhaps because the
resutls are so disappointing ;)

