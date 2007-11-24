From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/8] ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
Date: Fri, 23 Nov 2007 20:58:51 -0500
Message-ID: <4747855B.5060606@garzik.org>
References: <200711212302.lALN2tJG013658@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Emilian.Medve@Freescale.com,
	davem@davemloft.net, galak@gate.crashing.org, leoli@Freescale.com,
	paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41852 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303AbXKXB64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 20:58:56 -0500
In-Reply-To: <200711212302.lALN2tJG013658@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Emil Medve <Emilian.Medve@Freescale.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Kumar Gala <galak@gate.crashing.org>
> Cc: Li Yang <leoli@freescale.com>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/ucc_geth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/ucc_geth.c~ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes drivers/net/ucc_geth.c
> --- a/drivers/net/ucc_geth.c~ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
> +++ a/drivers/net/ucc_geth.c
> @@ -3443,7 +3443,7 @@ static int ucc_geth_rx(struct ucc_geth_p
>  	u16 length, howmany = 0;
>  	u32 bd_status;
>  	u8 *bdBuffer;
> -	struct net_device * dev;
> +	struct net_device *dev;

ACK with a fixed description...


