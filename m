From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 01/12] fsl/fman: Add the FMan FLIB headers
Date: Wed, 10 Jun 2015 13:54:06 -0500
Message-ID: <1433962446.2477.121.camel@freescale.com>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>,
	Igal Liberman <Igal.Liberman@freescale.com>
To: <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:57792
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751660AbbFJSyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 14:54:15 -0400
In-Reply-To: <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-10 at 18:21 +0300, Madalin Bucur wrote:
> From: Igal Liberman <Igal.Liberman@freescale.com>
> 
> This patch presents the FMan Foundation Libraries (FLIB) headers.
> The FMan FLib provides the basic API used by the FMan drivers to
> configure and control the FMan hardware.
> 
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
>  .../ethernet/freescale/fman/flib/common/general.h  |  41 ++
>  .../net/ethernet/freescale/fman/flib/fsl_fman.h    | 609 
> +++++++++++++++++++++
>  2 files changed, 650 insertions(+)
>  create mode 100644 
> drivers/net/ethernet/freescale/fman/flib/common/general.h
>  create mode 100644 
> drivers/net/ethernet/freescale/fman/flib/fsl_fman.h

Why do we need separate patches just for headers?

What does "common" refer to?

What does the flib directory mean, in the context of Linux?  If 
someone were to add code to this driver, how do they know if the code 
should go into the flib directory or not?

> 
> +#define iowrite32be(val, addr)               out_be32(&(*addr), val)
> +#define ioread32be(addr)             in_be32(&(*addr))

iowrite32be()/ioread32be() are already defined for all relevant 
architectures.  Why are you redefining them into something PPC-
specific?

> +/* do not change! if changed, must be disabled for rev1 ! */
> +#define DEFAULT_HALT_ON_EXTERNAL_ACTIVATION  false
> +/* do not change! if changed, must be disabled for rev1 ! */
> +#define DEFAULT_HALT_ON_UNRECOVERABLE_ECC_ERROR false

rev1 of what chip?

-Scott
