From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net: ethernet: davicom: Allow to select DM9000 for
 nios2
Date: Fri, 12 Dec 2014 09:49:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0BA4C@AcuExch.aculab.com>
References: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Tobias Klauser' <tklauser@distanz.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34982 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934676AbaLLJuW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 04:50:22 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12235-07 for <netdev@vger.kernel.org>;
 Fri, 12 Dec 2014 09:50:13 +0000 (GMT)
In-Reply-To: <1418376071-28709-1-git-send-email-tklauser@distanz.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser
> This chip is present on older revisions of the DE2 development kit.

Doesn't that mean the selector should be DE2 not NIOS2.

NIOS2 is a cpu not a board and I think this is an external peripheral
not something implemented in the fpga itself.

	David

> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/davicom/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
> index 316c5e5..7ec2d74 100644
> --- a/drivers/net/ethernet/davicom/Kconfig
> +++ b/drivers/net/ethernet/davicom/Kconfig
> @@ -4,7 +4,7 @@
> 
>  config DM9000
>  	tristate "DM9000 support"
> -	depends on ARM || BLACKFIN || MIPS || COLDFIRE
> +	depends on ARM || BLACKFIN || MIPS || COLDFIRE || NIOS2
>  	select CRC32
>  	select MII
>  	---help---
> --
> 2.2.0
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
