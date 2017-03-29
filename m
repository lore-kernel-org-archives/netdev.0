From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] net: dsa: dsa2: Add basic support of devlink
Date: Wed, 29 Mar 2017 03:31:12 +0200
Message-ID: <20170329013112.GF3152@lunn.ch>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
 <1490737507-7864-3-git-send-email-andrew@lunn.ch>
 <2fe7ffc9-1bf1-537a-e361-33156a6f5a07@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2fe7ffc9-1bf1-537a-e361-33156a6f5a07-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 05:33:18PM -0700, Florian Fainelli wrote:
> On 03/28/2017 02:45 PM, Andrew Lunn wrote:
> > Register the switch and its ports with devlink.
> > 
> > Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> 
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Tested-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> root@net-vm:~# devlink -p port
> mdio_bus/fixed-0:1f/0: type eth netdev lan1
> mdio_bus/fixed-0:1f/1: type eth netdev lan2
> mdio_bus/fixed-0:1f/2: type eth netdev lan3
> mdio_bus/fixed-0:1f/3: type eth netdev lan4
> mdio_bus/fixed-0:1f/5: type notset
> root@net-vm:~# devlink -p dev
> mdio_bus/fixed-0:1f

Thanks Florian

I have another patch somewhere which adds new types for CPU and DSA
ports. Once these 2 patches have landed, and the reports of broken
builds stop, i will dig it out.

But my main priority at the moment is to play with dpipe and make sure
it can represent tables we have in DSA switches, before the Binary API
is frozen.

       Andrew
