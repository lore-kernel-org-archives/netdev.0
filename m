From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Thu, 18 Aug 2011 20:36:32 +0100
Message-ID: <20110818193632.GA27388@linux-mips.org>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Russell King <linux@arm.linux.org.uk>,
	Hamish Coleman <hamish@zot.apana.org.au>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:41815 "EHLO linux-mips.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751295Ab1HRTgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 15:36:53 -0400
Content-Disposition: inline
In-Reply-To: <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2011 at 12:32:57AM -0700, Jeff Kirsher wrote:

> Move the drivers that use SEEQ chipset into drivers/net/ethernet/seeq
> and make the necessary Kconfig and Makefile changes.
> 
> CC: Russell King <linux@arm.linux.org.uk>
> CC: Hamish Coleman <hamish@zot.apana.org.au>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                                 |    3 +-
>  drivers/net/Kconfig                         |   18 -----------
>  drivers/net/Makefile                        |    2 -
>  drivers/net/arm/Kconfig                     |    7 ----
>  drivers/net/arm/Makefile                    |    1 -
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/seeq/Kconfig           |   45 +++++++++++++++++++++++++++
>  drivers/net/ethernet/seeq/Makefile          |    7 ++++
>  drivers/net/{arm => ethernet/seeq}/ether3.c |    0
>  drivers/net/{arm => ethernet/seeq}/ether3.h |    0
>  drivers/net/{ => ethernet/seeq}/seeq8005.c  |    0
>  drivers/net/{ => ethernet/seeq}/seeq8005.h  |    0
>  drivers/net/{ => ethernet/seeq}/sgiseeq.c   |    0
>  drivers/net/{ => ethernet/seeq}/sgiseeq.h   |    0
>  15 files changed, 56 insertions(+), 29 deletions(-)
>  create mode 100644 drivers/net/ethernet/seeq/Kconfig
>  create mode 100644 drivers/net/ethernet/seeq/Makefile
>  rename drivers/net/{arm => ethernet/seeq}/ether3.c (100%)
>  rename drivers/net/{arm => ethernet/seeq}/ether3.h (100%)
>  rename drivers/net/{ => ethernet/seeq}/seeq8005.c (100%)
>  rename drivers/net/{ => ethernet/seeq}/seeq8005.h (100%)
>  rename drivers/net/{ => ethernet/seeq}/sgiseeq.c (100%)
>  rename drivers/net/{ => ethernet/seeq}/sgiseeq.h (100%)

This makes a lot more sense than shoving the Seeq drivers into
drivers/net/ethernet/sgi/ - even though sgiseeq depends on an SGI IP22/IP28
specific DMA engine.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
