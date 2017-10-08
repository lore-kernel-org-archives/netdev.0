From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Sun, 8 Oct 2017 07:59:06 -0400
Message-ID: <20171008115902.xsd3a7a7fslcljdj@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
 <20170928165643.GB14940@lunn.ch>
 <CO2PR04MB218421921CC649BC026F34669F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CO2PR04MB218421921CC649BC026F34669F7E0@CO2PR04MB2184.namprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2017 at 03:28:02PM +0000, Brandon Streiff wrote:
> 
> NETWORK_PHY_TIMESTAMPING implies NET_PTP_CLASSIFY (which I do use)
> and net/core/timestamping.c (which I didn't). It probably makes more
> sense to just depend on NET_PTP_CLASSIFY directly.

Yes, that makes sense to do, if you can make it work.

With my driver I tried depending on NET_PTP_CLASSIFY, but there was
some Kconfig issue, and rather than figuring it out I did the lazy
thing and used NETWORK_PHY_TIMESTAMPING.

Thanks,
Richard
