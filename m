From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] selftests: add a generic testsuite for ethernet device
Date: Tue, 4 Apr 2017 16:24:54 +0200
Message-ID: <20170404142454.GC1736@lunn.ch>
References: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shuah@kernel.org, davem@davemloft.net,
        linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45193 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754339AbdDDOZG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 10:25:06 -0400
Content-Disposition: inline
In-Reply-To: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 04, 2017 at 03:32:47PM +0200, Corentin Labbe wrote:
> This patch add a generic testsuite for testing ethernet network device driver.

# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAUL0
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFA2
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFA2
    link/ether a2:e2:da:92:7e:8c brd ff:ff:ff:ff:ff:ff
4: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default0
    link/sit 0.0.0.0 brd 0.0.0.0
5: lan4@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state 0
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
6: lan3@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT0
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
7: lan2@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state 0
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
8: lan1@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP0
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff
9: internet@eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue st0
    link/ether 94:10:3e:80:bc:f3 brd ff:ff:ff:ff:ff:ff

# /home/andrew/netdevice.sh 
[  151.417351] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
PASS: eth0: set interface up
PASS: eth0: set MAC address
SKIP: eth0: set IP address
PASS: eth0: ethtool list features
Cannot get register dump: Operation not supported
SKIP: eth0: ethtool dump not supported
PASS: eth0: ethtool stats
PASS: eth0: stop interface
SKIP: eth1: interface already up
PASS: eth1: ethtool list features
Cannot get register dump: Operation not supported
SKIP: eth1: ethtool dump not supported
PASS: eth1: ethtool stats
SKIP: eth1: interface kept up
PASS: eth0: set interface up
PASS: lan4: set MAC address
    inet 192.168.13.2/24 brd 192.168.13.255 scope global lan4
SKIP: lan4: already have an IP
PASS: lan4: ethtool list features
PASS: lan4: ethtool dump
PASS: lan4: ethtool stats
PASS: eth0: stop interface
PASS: eth0: set interface up
PASS: lan3: set MAC address
SKIP: lan3: set IP address
PASS: lan3: ethtool list features
PASS: lan3: ethtool dump
PASS: lan3: ethtool stats
PASS: eth0: stop interface
PASS: eth0: set interface up
PASS: lan2: set MAC address
SKIP: lan2: set IP address
PASS: lan2: ethtool list features
PASS: lan2: ethtool dump
PASS: lan2: ethtool stats
PASS: eth0: stop interface
PASS: eth0: set interface up
PASS: lan1: set MAC address
    inet 10.0.0.12/24 brd 10.0.0.255 scope global lan1
SKIP: lan1: already have an IP
PASS: lan1: ethtool list features
PASS: lan1: ethtool dump
PASS: lan1: ethtool stats
PASS: eth0: stop interface
PASS: eth0: set interface up
PASS: internet: set MAC address
    inet 192.168.10.2/24 brd 192.168.10.255 scope global internet
SKIP: internet: already have an IP
PASS: internet: ethtool list features
PASS: internet: ethtool dump
PASS: internet: ethtool stats
PASS: eth0: stop interface

Cool

Tested-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
