From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: dsa: b53: Add missing ARL entries for BCM53125
Date: Thu, 20 Jul 2017 17:41:20 -0400
Message-ID: <87inimss5b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170720192522.18048-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720192522.18048-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli <f.fainelli@gmail.com> writes:

> The BCM53125 entry was missing an arl_entries member which would
> basically prevent the ARL search from terminating properly. This switch
> has 4 ARL entries, so add that.
>
> Fixes: 1da6df85c6fb ("net: dsa: b53: Implement ARL add/del/dump operations")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
