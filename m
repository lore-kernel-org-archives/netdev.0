From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/9] net: dsa: mv88e6xxx: program the PVT
 with all ones
Date: Fri, 31 Mar 2017 18:35:12 +0200
Message-ID: <20170331163512.GH12814@lunn.ch>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
 <20170330213715.9666-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41954 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933431AbdCaQfO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 12:35:14 -0400
Content-Disposition: inline
In-Reply-To: <20170330213715.9666-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 30, 2017 at 05:37:09PM -0400, Vivien Didelot wrote:
> The Cross-chip Port Based VLAN Table (PVT) is currently initialized with
> all ones, allowing any external ports to egress frames on local ports.
> 
> This commit implements the PVT access functions and programs the PVT
> with all ones for the local switch ports only, instead of using the Init
> operation. The current behavior is unchanged for the moment.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
