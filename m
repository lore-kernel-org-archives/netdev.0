From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dma-mapping.h
Date: Fri, 02 Mar 2007 19:43:34 -0500
Message-ID: <45E8C4B6.4050302@garzik.org>
References: <1171651858.16919.14.camel@dhcp-10-7-81-58.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gary Zambrano <zambrano@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55237 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992809AbXCCAnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 19:43:37 -0500
In-Reply-To: <1171651858.16919.14.camel@dhcp-10-7-81-58.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gary Zambrano wrote:
> Added dma_sync_single_range_for_cpu/device to dma-mapping.h in asm-arm &
> asm-avr32 to call dma_sync_single_for_cpu/device. This patch enables b44
> to compile on systems with these cpus.
> This patch was created with the assumption that another method of
> dma_sync_single_range_for_cpu/device does not exist on these
> architectures.
> 
> 
> Signed-off by: Gary Zambrano <zambrano@broadcom.com>

this patch looks OK to me, but I'm not the one to apply it.  This should 
go through Andrew or linux-arch

	Jeff, passing the buck



