From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: kill unused include
Date: Sat, 25 Aug 2007 00:37:14 -0400
Message-ID: <46CFB1FA.1040705@garzik.org>
References: <Pine.LNX.4.64.0708222144440.6464@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Li Yang <leoli@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56070 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbXHYEhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:37:22 -0400
In-Reply-To: <Pine.LNX.4.64.0708222144440.6464@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> The ucc_geth_mii code is based on the gianfar_mii code that use to include
> ocp.h.  ucc never need this and it causes issues when we want to kill
> arch/ppc includes from arch/powerpc.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
> 
> Jeff, if you issue with this for 2.6.23, I'd prefer to push this via
> the powerpc.git trees in 2.6.24 as part of a larger cleanup.  Let me know
> one way or the other.
> 
> - k
> 
>  drivers/net/ucc_geth_mii.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
> index 6c257b8..df884f0 100644
> --- a/drivers/net/ucc_geth_mii.c
> +++ b/drivers/net/ucc_geth_mii.c
> @@ -32,7 +32,6 @@
>  #include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/platform_device.h>
> -#include <asm/ocp.h>
>  #include <linux/crc32.h>
>  #include <linux/mii.h>

Feel free to push via PPC git


