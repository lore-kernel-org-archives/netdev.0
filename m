From: Romain Perier <romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 0/3] Add support for the ethernet switch on the
 ESPRESSObin
Date: Tue, 20 Dec 2016 09:53:29 +0100
Message-ID: <1fa806aa-1c8f-64c5-8b86-13dc4fd2d1ee@free-electrons.com>
References: <20161220085138.3998-1-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161220085138.3998-1-romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Le 20/12/2016 à 09:51, Romain Perier a écrit :
> This set of patches adds support for the Marvell ethernet switch 88E6341.
> It also add the devicetree definition of this switch to the DT board.
>
> Romain Perier (3):
>   net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >=
>     num_of_ports
>   net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341/88E6141
>   arm64: dts: marvell: Add ethernet switch definition for the
>     ESPRESSObin
>
>  .../boot/dts/marvell/armada-3720-espressobin.dts   | 67 ++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx/chip.c                   | 48 ++++++++++++++--
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  4 +-
>  3 files changed, 112 insertions(+), 7 deletions(-)
>

Oh and I rebased the whole series onto net-next.

Romain
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
