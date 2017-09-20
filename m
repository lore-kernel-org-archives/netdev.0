From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: Utilize dsa_slave_dev_check()
Date: Wed, 20 Sep 2017 10:19:39 -0400
Message-ID: <871sn178qs.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170920010038.12393-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920010038.12393-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Instead of open coding the check.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

If we do need to use it outside one day, we may think about renaming
netdev_uses_dsa() to netdev_is_dsa_master() and renaming
dsa_slave_dev_check() to netdev_is_dsa_slave().

In the meantime, looks good!

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
