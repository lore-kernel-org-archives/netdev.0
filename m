From: Pavel Machek <pavel@ucw.cz>
Subject: e1000e on Thinkpad x60: gigabit not available due to "SmartSpeed"
Date: Thu, 1 Sep 2016 22:14:27 +0200
Message-ID: <20160901201408.GA5061@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kernel list <linux-kernel@vger.kernel.org>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I have trouble getting 1000mbit out of my ethernet card.

I tried direct connection between two PCs with different cables, and
no luck.

Today I tried connection to 1000mbit switch, and no luck, either. (Two
cables, one was cat6, both short).

My computer sees 1000mbit being advertised by the other side, but does
not advertise 1000mbit, "Link Speed was downgraded by SmartSpeed".

4.8.0-rc4+ kernel.

Does it work for other people? Card is:

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet
Controller

root@duo:/data/l/linux# mii-tool -v eth1
SIOCGMIIREG on eth1 failed: Input/output error
SIOCGMIIREG on eth1 failed: Input/output error
eth1: negotiated 100baseTx-FD, link ok
  product info: Yukon-EC 88E1111 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
root@duo:/data/l/linux#

[ 1330.622658] e1000e: eth1 NIC Link is Up 100 Mbps Full Duplex, Flow
Control: None
[ 1330.622840] e1000e 0000:02:00.0 eth1: Link Speed was downgraded by
SmartSpeed
[ 1330.622846] e1000e 0000:02:00.0 eth1: 10/100 speed: disabling TSO
root@duo:/data/l/linux#

Best regards,

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
