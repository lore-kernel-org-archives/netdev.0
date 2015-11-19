From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: Add support for a switch reset
 gpio
Date: Thu, 19 Nov 2015 04:06:05 +0100
Message-ID: <20151119030605.GG25930@lunn.ch>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36983 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754900AbbKSDGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 22:06:08 -0500
Content-Disposition: inline
In-Reply-To: <1447889365-25256-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> index 1eba07feb34a..39cd19eaaf4e 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -21,6 +21,8 @@
>  #include <linux/of_mdio.h>
>  #include <linux/of_platform.h>
>  #include <linux/of_net.h>
> +#include <linux/nvmem-consumer.h>

Comment to self:

That include should not be there.

I will post a v2 once the discussion has stopped.

  Andrew
