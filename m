From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] netxen: fix warnings
Date: Fri, 09 Mar 2007 11:47:50 -0500
Message-ID: <45F18FB6.2090701@garzik.org>
References: <20070306203537.GA5822@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amitkale@netxen.com, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57710 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767368AbXCIQsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:48:04 -0500
In-Reply-To: <20070306203537.GA5822@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
>   CC [M]  drivers/net/netxen/netxen_nic_hw.o
> drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_hw_resources':
> drivers/net/netxen/netxen_nic_hw.c:231: warning: format '%llx' expects type 'long long unsigned int', but argument 2 has type 'dma_addr_t'
> drivers/net/netxen/netxen_nic_hw.c:250: warning: format '%llx' expects type 'long long unsigned int', but argument 2 has type 'dma_addr_t'
> 
> u64 is unsigned long so the cast to u64 will result in a warning on the
> printf arguments for 64-bit builds.  So cast to unsigned long long instead.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


