From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/2] net: dsa: bcm_sf2: Do not clobber b53_switch_ops
Date: Sun, 8 Jan 2017 21:16:45 +0100
Message-ID: <20170108201645.GE21101@lunn.ch>
References: <20170108050157.16302-1-f.fainelli@gmail.com>
 <20170108050157.16302-2-f.fainelli@gmail.com>
 <20170108174105.GA21101@lunn.ch>
 <37a65faf-93f1-067a-cd85-55d96b0631cc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48669 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934677AbdAHUQu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 15:16:50 -0500
Content-Disposition: inline
In-Reply-To: <37a65faf-93f1-067a-cd85-55d96b0631cc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Agreed, and this was my initial approach, but I also wanted a minimal
> fix for David to pull into "net" while we can properly resolve this for
> "net-next" see below.

O.K, so in that case, this is fine.

> Making the ops const was my initial approach but there are several
> challenges to making it possible right now which I will address against
> net-next:
> 
> - register/unregister_switch_driver actually do modify dsa_switch_ops
> while updating the list pointer, so we need to encapsulate
> dsa_switch_ops into a dsa_switch_driver plus a list member

O.K, this is dsa v1. I had v2 in mind. Yes, the list needs
abstracting.

	Thanks
		Andrew
