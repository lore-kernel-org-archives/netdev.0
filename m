From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Thu, 3 Aug 2006 18:21:08 +0200
Message-ID: <20060803162108.GK31534@deprecation.cyrius.com>
References: <20060728104946.GA6710@electric-eye.fr.zoreil.com> <20060728111534.GD25854@xi.wantstofly.org> <20060728115237.GF21733@deprecation.cyrius.com> <20060728194933.GA14222@electric-eye.fr.zoreil.com> <20060728203437.GA6253@deprecation.cyrius.com> <20060802180244.GA32235@deprecation.cyrius.com> <20060802221629.GB28282@electric-eye.fr.zoreil.com> <20060803135349.GH31534@deprecation.cyrius.com> <20060803142309.GA17166@deprecation.cyrius.com> <20060803150556.GA9433@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:12301 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S932527AbWHCQVL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 12:21:11 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060803150556.GA9433@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-08-03 17:05]:
> Btw, can you pass the module a 'debug=32767' option when it is loaded to
> increase its verbosity.

That doesn't give me much more messages but now I get one error
message that is probably significant:

eth0: PCI error (cmd = 0x0157, status = 0x6238).


Full log:

r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
mac_version == Unknown
phy_version == RTL_GIGA_PHY_VER_D (0000)
eth0: Identified chip type is 'RTL8169s/8110s'.
eth0: RTL8169 at 0xc885e200, 00:14:fd:10:27:74, IRQ 27
mac_version == Unknown
phy_version == RTL_GIGA_PHY_VER_D (0000)
MAC version != 0 && PHY version == 0 or 1
Do final_reg2.cfg
Set MAC Reg C+CR Offset 0x82h = 0x01h
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
mac_version == Unknown
phy_version == RTL_GIGA_PHY_VER_D (0000)
eth1: Identified chip type is 'RTL8169s/8110s'.
eth1: RTL8169 at 0xc8860300, 00:14:fd:10:00:00, IRQ 28
mac_version == Unknown
phy_version == RTL_GIGA_PHY_VER_D (0000)
MAC version != 0 && PHY version == 0 or 1
Do final_reg2.cfg
Set MAC Reg C+CR Offset 0x82h = 0x01h
libata version 1.20 loaded.
...
Freeing init memory: 88K
Adding 506008k swap on /dev/sda5.  Priority:-1 extents:1
across:506008k
EXT3 FS on sda3, internal journal
r8169: eth0: link up
eth0: PCI error (cmd = 0x0157, status = 0x6238).
NETDEV WATCHDOG: eth0: transmit timed out
eth0: PCI error (cmd = 0x0157, status = 0x6238).

-- 
Martin Michlmayr
http://www.cyrius.com/
