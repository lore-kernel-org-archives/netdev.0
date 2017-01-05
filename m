From: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/2] Add support for the ethernet switch on the ESPRESSObin
Date: Thu, 05 Jan 2017 15:25:53 +0100
Message-ID: <87tw9dbn2m.fsf@free-electrons.com>
References: <20161221125734.1034-1-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Romain Perier <romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161221125734.1034-1-romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> (Romain
        Perier's message of "Wed, 21 Dec 2016 13:57:32 +0100")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,
 
 On mer., déc. 21 2016, Romain Perier <romain.perier-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:

> This set of patches adds support for the Marvell ethernet switch 88E6341.
> It also add the devicetree definition of this switch to the DT board.

The forth version of this series had been sent while the net-next merge
window was closed so I think it was missed.

Do you want that we send it again on the netdev mainling list?

Thanks,

Gregory

>
> Romain Perier (2):
>   net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >=
>     num_of_ports
>   net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341/88E6141
>
>  drivers/net/dsa/mv88e6xxx/chip.c      | 48 ++++++++++++++++++++++++++++++-----
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 ++-
>  2 files changed, 45 insertions(+), 7 deletions(-)
>
> -- 
>
> Note: As requested by Gregory, I have removed the patch for the DT (already merged).
>
> 2.9.3
>

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
