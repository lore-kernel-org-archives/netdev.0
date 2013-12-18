From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 8/9] net: phy: fix checkpatch errors
Date: Tue, 17 Dec 2013 22:07:53 -0800
Message-ID: <1387346873.13593.12.camel@joe-AO722>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
	 <1387345093-14168-9-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0103.hostedemail.com ([216.40.44.103]:39092 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751017Ab3LRGH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 01:07:57 -0500
In-Reply-To: <1387345093-14168-9-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 21:38 -0800, Florian Fainelli wrote:
> checkpatch spotted a few checkpatch errors such as whitespace damages
> and switch/case labels not being on the same column, fix them.

trivia:

> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
[]
> @@ -714,16 +714,16 @@ void phy_start(struct phy_device *phydev)
>  	mutex_lock(&phydev->lock);
>  
>  	switch (phydev->state) {
> -		case PHY_STARTING:
> -			phydev->state = PHY_PENDING;
> -			break;
> -		case PHY_READY:
> -			phydev->state = PHY_UP;
> -			break;
> -		case PHY_HALTED:
> -			phydev->state = PHY_RESUMING;
> -		default:
> -			break;
> +	case PHY_STARTING:
> +		phydev->state = PHY_PENDING;
> +		break;
> +	case PHY_READY:
> +		phydev->state = PHY_UP;
> +		break;
> +	case PHY_HALTED:
> +		phydev->state = PHY_RESUMING;

This should have a break here and not
rely on the fallthrough.

> +	default:
> +		break;
>  	}
>  	mutex_unlock(&phydev->lock);
>  }
