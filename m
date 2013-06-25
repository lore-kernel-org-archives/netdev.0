From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 2/7] alx: fix 100mbit/full duplex speed translation
Date: Tue, 25 Jun 2013 12:32:28 -0700
Message-ID: <1372188748.1245.77.camel@joe-AO722>
References: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
	 <1372185503-24705-3-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45468 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751102Ab3FYTc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 15:32:29 -0400
In-Reply-To: <1372185503-24705-3-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 20:38 +0200, Johannes Berg wrote:
> 100mbit full duplex is ADVERTISED_100baseT_Half, not
> ADVERTISED_10baseT_Half.

Correct code, bad commit message.

> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
>  drivers/net/ethernet/atheros/alx/hw.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
> index 220a16a..dc71cfb 100644
> --- a/drivers/net/ethernet/atheros/alx/hw.c
> +++ b/drivers/net/ethernet/atheros/alx/hw.c
> @@ -1134,7 +1134,7 @@ static inline u32 alx_speed_to_ethadv(int speed)
>  	case SPEED_100 + DUPLEX_FULL:
>  		return ADVERTISED_100baseT_Full;
>  	case SPEED_100 + DUPLEX_HALF:
> -		return ADVERTISED_10baseT_Half;
> +		return ADVERTISED_100baseT_Half;
>  	case SPEED_10 + DUPLEX_FULL:
>  		return ADVERTISED_10baseT_Full;
>  	case SPEED_10 + DUPLEX_HALF:
