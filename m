From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] sis190: add new phy found on asus F5 series laptops
Date: Tue, 2 Jun 2009 23:18:10 +0200
Message-ID: <20090602211810.GA26871@electric-eye.fr.zoreil.com>
References: <cover.1244012631.git.birrachiara@tin.it> <20090603095236.GA15414@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Riccardo Ghetta <birrachiara@tin.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46656 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbZFBVQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:16:26 -0400
Content-Disposition: inline
In-Reply-To: <20090603095236.GA15414@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Riccardo Ghetta <birrachiara@tin.it> :
> Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
> ---
>  drivers/net/sis190.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index 55ccd51..3d4542e 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
> @@ -317,6 +317,7 @@ static struct mii_chip_info {
>          unsigned int type;
>  	u32 feature;
>  } mii_chip_table[] = {
> +	{ "Atheros PHY ?",        { 0x004d, 0xd010 }, LAN, 0 },
>  	{ "Atheros PHY AR8012",   { 0x004d, 0xd020 }, LAN, 0 },
>  	{ "Broadcom PHY BCM5461", { 0x0020, 0x60c0 }, LAN, F_PHY_BCM5461 },
>  	{ "Broadcom PHY AC131",   { 0x0143, 0xbc70 }, LAN, 0 },

Please be more specific with the identifier of your laptop. Afaiu some
laptops in the F5 series include network components from Realtek. It could
be confusing.

You can remove the question mark. If we can only tell that the phy comes
from Atheros, so be it.

-- 
Ueimor
