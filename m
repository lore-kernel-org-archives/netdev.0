From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 2/2] net: dsa: dsa2: Add basic support of devlink
Date: Wed, 29 Mar 2017 19:36:24 +0200
Message-ID: <20170329173624.GE7942@lunn.ch>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
 <1490737507-7864-3-git-send-email-andrew@lunn.ch>
 <2fe7ffc9-1bf1-537a-e361-33156a6f5a07@gmail.com>
 <20170329013112.GF3152@lunn.ch>
 <c844a885-cfd3-4358-89dd-c619d3d394e4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c844a885-cfd3-4358-89dd-c619d3d394e4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Tangential question: we do not currently report to user space what kind
> of switch tagging protocol is used (DSA, eDSA etc.) I was going to add a
> sysfs attribute for that under the switch device's directory, but maybe
> devlink would be more appropriate for that?

We don't report it. What are you thinking you want to do with this
information?

I suppose it might be possible to teach libpcap/tcpdump about it, so
it can slide in an additional dissector. EDSA you can detect anyway,
since it uses a well know Ethertype. tcpdump already supports
this. But the other tag protocols cannot be detected.

devlink does seem like a good candidate for this, make it part of the
port type.

     Andrew
