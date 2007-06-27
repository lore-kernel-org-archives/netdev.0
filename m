From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] au1000_eth: Fix warnings.
Date: Wed, 27 Jun 2007 02:33:19 -0400
Message-ID: <468204AF.9050606@garzik.org>
References: <20070624135953.GA16754@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37833 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754692AbXF0GdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 02:33:24 -0400
In-Reply-To: <20070624135953.GA16754@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> Fixed by including <linux/dma-mapping.h>:
> 
>   CC      drivers/net/au1000_eth.o
> drivers/net/au1000_eth.c: In function 'au1000_probe':
> drivers/net/au1000_eth.c:661: warning: implicit declaration of function 'dma_alloc_noncoherent'
> drivers/net/au1000_eth.c:802: warning: implicit declaration of function 'dma_free_noncoherent'
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied to #upstream-fixes


