From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 16:02:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


At 55k, I doubt you want to see it posted to the list; patch is available from

http://ftp.linux.org.uk/pub/linux/willy/patches/ethtool4.diff

and here's the diffstat

 drivers/net/8139too.c     |  330 ++++++++--------------
 drivers/net/tg3.c         |  584 ++++++++++++++++------------------------
 include/linux/ethtool.h   |  100 ++++++
 include/linux/netdevice.h |    5 
 net/core/Makefile         |    4 
 net/core/dev.c            |   16 -
 net/core/ethtool.c        |  671 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1154 insertions(+), 556 deletions(-)

Patch has received light testing on an rtl8139c card:

Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 32
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: d
        Current message level: 0xffffffff (-1)
        Link detected: yes

but obviously it doesn't support all the ethtool options that some
cards do.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
