From: Tino Keitel <tino.keitel@tikei.de>
Subject: Regression: Wake on LAN doesn't work in sky2 with 2.6.33-rc4-git2
Date: Fri, 15 Jan 2010 10:10:53 +0100
Message-ID: <20100115091053.GA5477@mac.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756954Ab0AOJRL@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

wake on LAN doesn't work with 2.6.33-rc4-git2 on the following
hardware:

01:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
88E8053 PCI-E Gigabit Ethernet Controller [11ab:4362] (rev 22)

It worked with 2.6.32. In my suspend script, I enable WoL using
ethtool:

ethtool -s eth0 wol g

in dmesg, I get these messages at suspend:

sky2 eth0: disabling interface
sky2 0000:01:00.0: PME# enabled
sky2 0000:01:00.0: wake-up capability enabled by ACPI

and at resume:

sky2 0000:01:00.0: wake-up capability disabled by ACPI
sky2 0000:01:00.0: PME# disabled

Regards,
Tino
