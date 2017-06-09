From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/7] net: dsa: mv888e6xxx: do not use netdev
 printing
Date: Fri, 9 Jun 2017 15:16:10 +0200
Message-ID: <20170609131610.GA20756@lunn.ch>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
 <20170608223414.594-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43177 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751666AbdFINQP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 09:16:15 -0400
Content-Disposition: inline
In-Reply-To: <20170608223414.594-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 06:34:08PM -0400, Vivien Didelot wrote:
> The mv888e6xxx driver accesses a port's netdev mostly for printing.
> 
> This is bad for 2 reasons: DSA and CPU ports do not have a netdev
> pointer; it doesn't give us a correct picture of why a DSA driver might
> need to access a port's netdev.
> 
> Instead simply use dev_* printing functions with chip->dev (or ds->dev
> depending on the scope, both guaranteed to exist), with a p%d prefix for
> the target port.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
