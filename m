From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] smc911x
Date: Tue, 26 Dec 2006 16:30:22 -0500
Message-ID: <4591946E.2000404@garzik.org>
References: <45881B41.1070109@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41475 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932795AbWLZVa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:30:27 -0500
To: Pierre TARDY <pierre.tardy@freescale.com>
In-Reply-To: <45881B41.1070109@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pierre TARDY wrote:
> Attached a patch on smc911x driver, which corrects obvious errors in the 
> 16bit chips support of this driver.
> 
> Please note that this driver still do NOT support 16bit chips (9115 and 
> 9117), as it claims to, there may be mistakes in the data fifo 
> managment, this patch enable the driver to init the chip, but the data 
> is then corrupted.
> 
> I managed to make my chip work with the driver smsc911x (out of the 
> box), from smsc, which has been refused to be included in the kernel tree.
> http://thread.gmane.org/gmane.linux.network.general/10498/focus=40384
> 
> I think it my be a good idea to reconsider this choice
> - smsc911x has more chance to be supported as it has originally been 
> made by the manufacturer of the chip.
> - smc911x is mono chip (do not work with 9117 at least), mono arch and 
> mono plateform (restricted to PXA), while smsc911x has been tested on 
> various chips by smsc
> 
> The only thing that is missing in smsc911x is dma support, which is very 
> architecture dependant ( There is one way to do dma with the pxa, 
> another on the freescale mxc plateforms, another on the x86..)

ACK the patch, but please follow standard patch format 
(http://linux.yyz.us/patch-format.html), chiefly you should always 
include a Signed-off-by line, and avoid MIME attachments.

	Jeff




