From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: dsa: Move skb_unshare() to
 dsa_switch_rcv()
Date: Fri, 7 Apr 2017 22:56:09 +0200
Message-ID: <20170407205609.GD7966@lunn.ch>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
 <20170407204154.9651-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50317 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754955AbdDGU4L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 16:56:11 -0400
Content-Disposition: inline
In-Reply-To: <20170407204154.9651-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 01:41:53PM -0700, Florian Fainelli wrote:
> All DSA tag receive functions need to unshare the skb before mangling it, move
> this to the generic dsa_switch_rcv() function which will allow us to make the
> tag receive function return their mangled skb without caring about freeing a
> NULL skb.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
