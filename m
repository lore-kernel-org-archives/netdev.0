From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] network configs: disconnect network options from drivers
Date: Thu, 31 Mar 2005 20:22:28 +0200
Message-ID: <20050331182228.GV3086@postel.suug.ch>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ioe-lkml@axxeo.de, matthew@wil.cx, lkml <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <randy.dunlap@verizon.net>
Content-Disposition: inline
In-Reply-To: <20050330234709.1868eee5.randy.dunlap@verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Randy.Dunlap <20050330234709.1868eee5.randy.dunlap@verizon.net> 2005-03-30 23:47
> 
> RFC:  This is a work-in-progress (WIP), not yet completed.
> 
> A few people dislike that the Networking Options menu is inside
> the Device Drivers/Networking menu.  This patch moves the
> Networking Options menu to immediately before the Device Drivers menu,
> renames it to "Networking options and protocols", & moves most
> protocols to more logical places (IMHOOC).

Definitely a good idea.

> The reasons that it is still WIP are:
> - I'd like to see all of the sub-menus done in the same style;

Further suggestions:

 - Introduce sub menus on separate pages for TCP/IP, DECNet,
   ATM, ... i.e. like it is done for SCTP.

 - Separate things into top categories
     Socket Families (maybe separate page)
       - PF_PACKET
       - PF_UNIX
       - PF_KEY
     Protocols (separate page)
       - TCP/IP networking (separate page)
          - IPv6 (affecting choices below)
             - Privary extensions
          - multicasting
          - routing
             - advanced router
                - policy routing
                   - use nfmark with chaching support
                - multipath routing
                   - cached
                      - rrd
                      - random
                      - ...
             - multicast routing
                - pim v1
                - pim v2
             - verbose route monitoring
          - auto configuration
             - dhcp
             - boop
             - rarp
          - tunneling
             - IPv4
                - IPIP
                - GRE
                   - broadcast
             - IPv6
                - IPv6oIPv6
          - transformations
             - IPv4
                - AH
                - ESP
                - IPComp
             - IPv6
                - AH
                - ESP
                - IPComp
          - ARP daemon
          - TCP
             - Diagnostics
             - Syn Cookies
       - SCTP
       - ATM
       - 802.1d
       - 802.1q
       - DECnet
       - 802.2 LLC
       - IPX
       - Appletalk
       - X.25
       - LAPB
       - Econet
     <<Good title here>>
       - Netfilter
       - IPsec
       - LVS
       - Frame Diverter
       - QoS & Fair Queueing
       - Network testing
       - WAN Router

Thoughts?
