From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] qlge: New Qlogic 10Gb Ethernet Driver single patch
Date: Thu, 18 Sep 2008 12:10:01 -0400
Message-ID: <48D27D59.4020105@garzik.org>
References: <20080916203246.GA27264@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33830 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbYIRQKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:10:05 -0400
In-Reply-To: <20080916203246.GA27264@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
>>From c041fd2a648cc2685b21cb7e722ba9fb05be114e Mon Sep 17 00:00:00 2001
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Tue, 16 Sep 2008 12:17:52 -0700
> Subject: [PATCH 1/1] qlge: New Qlogic 10Gb Ethernet Driver.
> 
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  Documentation/networking/LICENSE.qlge |   46 +
>  MAINTAINERS                           |    7 +
>  drivers/net/Kconfig                   |    9 +
>  drivers/net/Makefile                  |    1 +
>  drivers/net/qlge/Makefile             |    7 +
>  drivers/net/qlge/qlge.h               | 1593 +++++++++++++
>  drivers/net/qlge/qlge_dbg.c           |  858 +++++++
>  drivers/net/qlge/qlge_ethtool.c       |  415 ++++
>  drivers/net/qlge/qlge_main.c          | 3954 +++++++++++++++++++++++++++++++++
>  drivers/net/qlge/qlge_mpi.c           |  150 ++
>  10 files changed, 7040 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/networking/LICENSE.qlge
>  create mode 100644 drivers/net/qlge/Makefile
>  create mode 100644 drivers/net/qlge/qlge.h
>  create mode 100644 drivers/net/qlge/qlge_dbg.c
>  create mode 100644 drivers/net/qlge/qlge_ethtool.c
>  create mode 100644 drivers/net/qlge/qlge_main.c
>  create mode 100644 drivers/net/qlge/qlge_mpi.c


applied, after fixing pci_dma_mapping_error() build breakage:  you only 
used one argument, when calling pci_dma_mapping_error().  I'm guessing 
that (a) you did not build test this on multiple platforms, both 32-bit 
and 64-bit, or (b) you are building against an older version of the kernel?

Either way, no big deal, I fixed it.  But that's something to watch for 
next time.  Your patches should always successfully build, ideally.


