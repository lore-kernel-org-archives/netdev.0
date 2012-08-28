From: Xyne <xyne@archlinux.ca>
Subject: jme driver: MAC spoofing issue
Date: Tue, 28 Aug 2012 00:03:58 +0000
Message-ID: <20120828000358.1b598294@archlinux.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy11-pub.bluehost.com ([173.254.64.10]:60018 "HELO
	oproxy11-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755108Ab2H1AcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 20:32:17 -0400
Received: from [83.154.192.247] (port=56630 helo=localhost.localdomain)
	by box539.bluehost.com with esmtpsa (SSLv3:AES128-SHA:128)
	(Exim 4.76)
	(envelope-from <xyne@archlinux.ca>)
	id 1T69Hm-0001P7-7j
	for netdev@vger.kernel.org; Mon, 27 Aug 2012 18:04:02 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was directed to post the following issue to this list. I apologize if this is
not the right place for it.

I have a laptop with an onboard JMicron ethernet controller. Relevant hwinfo
output along with additional system information are included at the end of the
message.

I am able to change the MAC address using macchanger, ip and ifconfig but I am
unable to obtain an IP address via DHCP (using dhcpcd or dhclient) after doing
so.

Aside from MAC spoofing, everything else works as expected.

I have posted more information in a thread on the Arch Linux forum [1]. I have
also packaged [2] and tested the upstream Git version of the driver [3], but
the issue persists.


Does anyone have any idea of how to resolve this? I have looked at the source
code but I do not know anything about network drivers. I hope that the solution
will be readily apparent to someone who is much more familiar with the code and
drivers in general.

Any help would be appreciated.


Best regards,
Xyne





hwinfo:
Model: "JMicron JMC250 PCI Express Gigabit Ethernet Controller"
Driver: "jme"
Driver Modules: "jme"
Device File: eth0
Driver Info #0:
  Driver Status: jme is active
  Driver Activation Cmd: "modprobe jme"
Config Status: cfg=new, avail=yes, need=no, active=unknown

System:
Arch Linux x86_64, fully updated
Kernel version: 3.4.9-1-ARCH


[1] https://bbs.archlinux.org/viewtopic.php?id=144253
[2] https://aur.archlinux.org/packages.php?ID=60649
[3] http://bbs.cooldavid.org/git/?p=jme.git
