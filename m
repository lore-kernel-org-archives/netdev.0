From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: unbalanced parenthesis fix
Date: Sat, 1 Sep 2007 13:55:39 +0100
Message-ID: <20070901135539.40557930@oldman>
References: <200709010810.12798.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34279 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965AbXIAMzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 08:55:19 -0400
In-Reply-To: <200709010810.12798.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 1 Sep 2007 08:10:12 +0200
Mariusz Kozlowski <m.kozlowski@tuxland.pl> wrote:

> Hello,
> 
> 	This patch fixes unbalanced parenthesis.
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/skge.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.23-rc4-mm1-a/drivers/net/skge.h	2007-09-01 07:23:52.000000000 +0200
> +++ linux-2.6.23-rc4-mm1-b/drivers/net/skge.h	2007-09-01 07:37:55.000000000 +0200
> @@ -1351,7 +1351,7 @@ enum {
>  	PHY_M_PC_EN_DET_PLUS	= 3<<8, /* Energy Detect Plus (Mode 2) */
>  };
> 
> -#define PHY_M_PC_MDI_XMODE(x)	((((u16)(x)<<5) & PHY_M_PC_MDIX_MSK)
> +#define PHY_M_PC_MDI_XMODE(x)	(((u16)(x)<<5) & PHY_M_PC_MDIX_MSK)
> 
>  enum {
>  	PHY_M_PC_MAN_MDI	= 0, /* 00 = Manual MDI configuration */

Since the macro is unused, I would rather just drop it.
