From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [NET][POWERPC] ucc_geth: really fix section mismatch
Date: Mon, 17 Dec 2007 16:03:58 -0500
Message-ID: <4766E43E.4050101@pobox.com>
References: <20071217115435.GA29857@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51256 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758006AbXLQVEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 16:04:09 -0500
In-Reply-To: <20071217115435.GA29857@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> Commit ed7e63a51d46e835422d89c687b8a3e419a4212a has tried to fix
> section mismatch:
> 
> WARNING: vmlinux.o(.init.text+0x17278): Section mismatch: reference to
> .exit.text:uec_mdio_exit (between 'ucc_geth_init' and 'uec_mdio_init')
> 
> But that mismatch still happens.
> 
> This patch actually fixing section mismatch by removing __exit from
> the header file.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  drivers/net/ucc_geth_mii.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
> index d834370..1e45b20 100644
> --- a/drivers/net/ucc_geth_mii.h
> +++ b/drivers/net/ucc_geth_mii.h
> @@ -96,5 +96,5 @@ enum enet_tbi_mii_reg {
>  int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
>  int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
>  int __init uec_mdio_init(void);
> -void __exit uec_mdio_exit(void);

applied #upstream-fixes


