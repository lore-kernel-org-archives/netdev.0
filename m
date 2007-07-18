From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH try#6] Blackfin ethernet driver: on chip ethernet MAC
 controller driver
Date: Wed, 18 Jul 2007 18:39:42 -0400
Message-ID: <469E96AE.4070105@garzik.org>
References: <1184654625.6503.21.camel@roc-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: michael.hennerich@analog.com, mb@bu3sch.de, vapier.adi@gmail.com,
	hch@infradead.org, dcbw@redhat.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	joe@perches.com, yoshfuji@linux-ipv6.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33171 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933939AbXGRWkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 18:40:08 -0400
In-Reply-To: <1184654625.6503.21.camel@roc-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Wu wrote:
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
> 
> [try#2]
>  - add timeout control
>  - kill dma_config_reg bitfields
>  - some trivial cleanup
> 
> [try#3]
>  - add endianess check
>  - add DRV_NAME, DRV_VERSION... driver information string
>  - add some comments for silicon anomaly and dma API confusion
>  - some code trivial cleanup
> 
> [try#4]
>  - add Blackfin latest GPIO pin mux opertion with Michael Hennerich's
>   help and Dan's review
>  - rewrite the DMA descriptor list operation in a more readable way
>   by Joe's review
> 
> [try#5]
>  - cleanup some coding style by Joe's review.
> 
> [try#6]
>  - 1.1 version fix a bug when set up multicast list pointed by Mr. yoshfuji
>  - rearrange the desc_list_free function.
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> Cc: Michael Buesch <mb@bu3sch.de>
> Cc: Mike Frysinger <vapier.adi@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Dan Williams <dcbw@redhat.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> ---
>  MAINTAINERS            |    7 +
>  drivers/net/Kconfig    |   44 +++
>  drivers/net/Makefile   |    1 +
>  drivers/net/bfin_mac.c | 1009 ++++++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/bfin_mac.h |  132 +++++++
>  5 files changed, 1193 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/bfin_mac.c
>  create mode 100644 drivers/net/bfin_mac.h

applied

