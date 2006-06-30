From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] mv643xx fixes - Disable interrupts on all ports during
 initialization
Date: Fri, 30 Jun 2006 12:20:43 -0400
Message-ID: <44A54F5B.4030902@garzik.org>
References: <200606270951.59024.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57786 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932386AbWF3QUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 12:20:46 -0400
To: Brent Cook <bcook@bpointsys.com>
In-Reply-To: <200606270951.59024.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brent Cook wrote:
> This patch disable interrupts on all ports during initialization. The current 
> assumes that the firmware has already disabled all interrupts on all ports. 
> We have encountered some boards that do not always disable interrupts (XES 
> XPedite 6200 for instance) on a soft reset. This patch prevents a kernel 
> panic if a packet is received before the DMA ring buffers are setup for a 
> port on which interrupts are left enabled by the firmware.
> 
> Signed-off-by: Brent Cook <bcook@bpointsys.com>

ACK patches 1-3, but:


[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
3 patch(es) to process.

Applying 'mv643xx fixes - Disable interrupts on all ports during 
initialization'
fatal: corrupt patch at line 19
