From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next] net: dsa: lan9303 Cpu port and ARL
Date: Mon, 23 Oct 2017 14:58:49 +0200
Message-ID: <20171023125849.GE6740@lunn.ch>
References: <20171023113506.13600-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:55457 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932210AbdJWM65 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 08:58:57 -0400
Content-Disposition: inline
In-Reply-To: <20171023113506.13600-1-privat@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> However, if some other (virtual) interface is added to the SW bridge, we still
> have the same problem. So I suspect that you want to see something like the 
> following: 

Yes, it would be good to have dynamic learning of MAC addresses on the
CPU port.

> ---
>  net/dsa/tag_lan9303.c | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
> index 57519597c6fc..1003fd91755c 100644
> --- a/net/dsa/tag_lan9303.c
> +++ b/net/dsa/tag_lan9303.c
> @@ -16,6 +16,7 @@
>  #include <linux/slab.h>
>  
>  #include "dsa_priv.h"
> +#include "../../drivers/net/dsa/lan9303.h"

Don't do that. Export the needed parts in an include file in
include/linux.

Otherwise, i think your approach is O.K.

	   Andrew
