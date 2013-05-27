From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3 net-next v3] net: ethtool: disambiguate XCVR_*
 meaning
Date: Mon, 27 May 2013 17:49:56 +0100
Message-ID: <1369673396.3469.389.camel@deadeye.wl.decadent.org.uk>
References: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
	 <1369307473-20696-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<afleming@freescale.com>, <jogo@openwrt.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15986 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900Ab3E0QuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 12:50:01 -0400
In-Reply-To: <1369307473-20696-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 12:11 +0100, Florian Fainelli wrote:
> Add a comment which explains the real meaning of XCVR_INTERNAL (PHY and
> Ethernet MAC in the same package/die) and XCVR_EXTERNAL (PHY and
> Ethernet MAC in a different package/die). Most if not all of the drivers
> setting their transceiver type already do it the way the comment
> describes it.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

I had another look over the drivers that use both values, and I think
there aren't any remaining exceptions to the definition you're giving.
Sorry for holding this up.

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

> ---
>  include/uapi/linux/ethtool.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 0c9b448..38dbafa 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -993,8 +993,8 @@ enum ethtool_sfeatures_retval_bits {
>  #define PORT_OTHER		0xff
>  
>  /* Which transceiver to use. */
> -#define XCVR_INTERNAL		0x00
> -#define XCVR_EXTERNAL		0x01
> +#define XCVR_INTERNAL		0x00 /* PHY and MAC are in the same package */
> +#define XCVR_EXTERNAL		0x01 /* PHY and MAC are in different packages */
>  #define XCVR_DUMMY1		0x02
>  #define XCVR_DUMMY2		0x03
>  #define XCVR_DUMMY3		0x04

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
