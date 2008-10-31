From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pci: use pci_ioremap_bar() in drivers/net
Date: Fri, 31 Oct 2008 00:56:15 -0400
Message-ID: <490A8FEF.5090200@garzik.org>
References: <20081020214239.398f1838@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52442 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbYJaE4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:56:19 -0400
In-Reply-To: <20081020214239.398f1838@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> Now that Linus added the pci_ioremap_bar() helper macro, this can go through
> 
> 
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Sun, 28 Sep 2008 16:17:08 -0700
> Subject: [PATCH] pci: use pci_ioremap_bar() in drivers/net
> 
> Use the newly introduced pci_ioremap_bar() function in drivers/net.
> pci_ioremap_bar() just takes a pci device and a bar number, with the goal
> of making it really hard to get wrong, while also having a central place
> to stick sanity checks.
> 
> CC: netdev@vger.kernel.org
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
>  drivers/net/bnx2x_main.c                 |    3 +--
>  drivers/net/e1000/e1000_main.c           |    7 ++-----
>  drivers/net/epic100.c                    |    2 +-
>  drivers/net/ixgb/ixgb_main.c             |    3 +--
>  drivers/net/qla3xxx.c                    |    4 +---
>  drivers/net/s2io.c                       |    6 ++----
>  drivers/net/wan/dscc4.c                  |    3 +--
>  drivers/net/wan/pc300too.c               |    2 +-
>  drivers/net/wan/pci200syn.c              |    2 +-
>  drivers/net/wireless/hostap/hostap_pci.c |    2 +-
>  drivers/net/wireless/ipw2200.c           |    2 +-
>  drivers/net/wireless/rt2x00/rt2x00pci.c  |    3 +--
>  12 files changed, 14 insertions(+), 25 deletions(-)

applied


