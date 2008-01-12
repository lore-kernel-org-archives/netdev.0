From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] r8169: fix missing loop variable increment
Date: Sat, 12 Jan 2008 17:41:48 -0500
Message-ID: <4789422C.20200@garzik.org>
References: <20080103223838.GA19191@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Citizen Lee @fr.zoreil.com" <citizen_lee@thecus.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51097 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758413AbYALWlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:41:50 -0500
In-Reply-To: <20080103223838.GA19191@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Spotted-by: Citizen Lee <citizen_lee@thecus.com>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/r8169.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 5863190..6ee9db1 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2002,7 +2002,7 @@ static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
>  	u32 clk;
>  
>  	clk = RTL_R8(Config2) & PCI_Clock_66MHz;
> -	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++) {
> +	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++, p++) {
>  		if ((p->mac_version == mac_version) && (p->clk == clk)) {
>  			RTL_W32(0x7c, p->val);

applied


