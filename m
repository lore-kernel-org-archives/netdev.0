From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibm_emac: Remove the ibm_emac driver
Date: Tue, 17 Jun 2008 23:30:56 -0400
Message-ID: <48588170.3010303@pobox.com>
References: <20080617193523.028d4cc2@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebs@ebshome.net, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41815 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102AbYFRDbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:31:04 -0400
In-Reply-To: <20080617193523.028d4cc2@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> The arch/ppc sub-tree has been removed in the powerpc git tree.  The old
> ibm_emac driver is no longer used by anything as a result of this.  This
> removes it, leaving the ibm_newemac driver as the proper driver to use for
> PowerPC boards with the EMAC hardware.
> 
> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> ---
>  MAINTAINERS                           |    8 -
>  drivers/net/Kconfig                   |    1 -
>  drivers/net/ibm_emac/Kconfig          |   70 -
>  drivers/net/ibm_emac/Makefile         |   11 -
>  drivers/net/ibm_emac/ibm_emac.h       |  329 -----
>  drivers/net/ibm_emac/ibm_emac_core.c  | 2263 ---------------------------------
>  drivers/net/ibm_emac/ibm_emac_core.h  |  222 ----
>  drivers/net/ibm_emac/ibm_emac_debug.c |  211 ---
>  drivers/net/ibm_emac/ibm_emac_debug.h |   62 -
>  drivers/net/ibm_emac/ibm_emac_mal.c   |  570 ---------
>  drivers/net/ibm_emac/ibm_emac_mal.h   |  267 ----
>  drivers/net/ibm_emac/ibm_emac_phy.c   |  398 ------
>  drivers/net/ibm_emac/ibm_emac_phy.h   |   80 --
>  drivers/net/ibm_emac/ibm_emac_rgmii.c |  200 ---
>  drivers/net/ibm_emac/ibm_emac_rgmii.h |   64 -
>  drivers/net/ibm_emac/ibm_emac_tah.c   |  110 --
>  drivers/net/ibm_emac/ibm_emac_tah.h   |   87 --
>  drivers/net/ibm_emac/ibm_emac_zmii.c  |  253 ----
>  drivers/net/ibm_emac/ibm_emac_zmii.h  |   82 --
>  19 files changed, 0 insertions(+), 5288 deletions(-)
>  delete mode 100644 drivers/net/ibm_emac/Kconfig
>  delete mode 100644 drivers/net/ibm_emac/Makefile
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_core.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_core.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_debug.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_debug.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_mal.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_mal.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_phy.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_phy.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_rgmii.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_rgmii.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_tah.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_tah.h
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_zmii.c
>  delete mode 100644 drivers/net/ibm_emac/ibm_emac_zmii.h

applied

