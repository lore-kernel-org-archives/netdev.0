From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/5] net-next: dsa: add Mediatek MT7530
 support
Date: Fri, 07 Apr 2017 13:53:02 -0700 (PDT)
Message-ID: <20170407.135302.1534365936334263631.davem@davemloft.net>
References: <1491554709-9723-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491554709-9723-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Date: Fri, 7 Apr 2017 16:45:04 +0800

> MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
> Mediatek router platforms such as MT7623A or MT7623N which includes 7-port
> Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY. Among these ports,
> The port from 0 to 4 are the user ports connecting with the remote devices
> while the port 5 and 6 are the CPU ports connecting into Mediatek Ethernet
> GMAC.
> 
> The patch series integrated Mediatek MT7530 into DSA support which
> includes the most of the essential callbacks such as tag insertion for
> port distinguishing, port control, bridge offloading, STP setup and
> ethtool operations to allow DSA to model each user port into independently
> standalone netdevice as the other DSA driver had done.

Series applied, thanks Sean.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
