From: Deepak Saxena <dsaxena@plexity.net>
Subject: Hermes PCI broken on 2.6.20?
Date: Thu, 8 Feb 2007 17:28:19 -0800
Message-ID: <20070209012819.GA23490@plexity.net>
Reply-To: dsaxena@plexity.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc11.comcast.net ([204.127.200.81]:42507 "EHLO
	sccrmhc11.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945994AbXBIBiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 20:38:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Running both 2.6.20 and 2.6.18, the hermes PCI driver (CONFIG_HERMES_PCI)
gives the following errors. Card is a revision 1 chipset (Dev ID 3873).
Note that when iwconfig is run a few times in a row, the error messages
go away but they might just be getting ratelimited. Anyone else seen
this?

root@10.40.20.173:~# iwconfig
eth0      no wirhermes @ c8810000: Card removed while waiting for command
0x0021 completion.
eless extensionshermes @ c8810000: Card removed while issuing command
0x0021.
.

lo        nhermes @ c8810000: Card removed while issuing command 0x0021.
o wireless extenhermes @ c8810000: Card removed while issuing command
0x0021.
sions.

eth1  hermes @ c8810000: Card removed while issuing command 0x0021.
    no wireless hermes @ c8810000: Card removed while issuing command
0x0011.
hermes @ c8810000: Card removed while issuing command 0x0021.
extensions.

hermes @ c8810000: Card removed while issuing command 0x0021.
hermes @ c8810000: Card removed while issuing command 0x0021.
eth2      IEEE 802.11-DS  ESSID:""  Nickname:"Prism  I"
          Mode:Managed  Bit Rate:11 Mb/s   
          RTS thr:off   
          Encryption key:off
          Link Quality:0  Signal level:0  Noise level:0
          Rx invalid nwid:0  invalid crypt:0  invalid misc:0

tunl0     no wireless extensions.

sit0      no wireless extensions.

ip6tnl0   no wireless extensions.

root@10.40.20.173:~# iwconfig eth2 essid qafarm-ap 
hermes @ c8810000: Card removed while issuing command 0x0011.
hermes @ c8810000: Card removed while issuing command 0x0021.
root@10.40.20.173:~# iwconfig eth2 essid qafarm-ap
printk: 3 messages suppressed.
hermes @ c8810000: Card removed while issuing command 0x0011.
root@10.40.20.173:~# iwconfig eth2 essid qafarm-ap
root@10.40.20.173:~# ifconfig eth2 10.40.20.200 netmask  255.255.252.0 up
hermes @ c8810000: BAP0 offset timeout: reg=0x8000 id=0xfc01 offset=0x0
eth2: Error -110 setting MAC address
eth2: Error -110 configuring card
SIOCSIFFLAGS: Coeth2: Error -110 setting MAC address
eth2: Error -110 configuring card
nnection timed out
SIOCSIFFLAGS: Connection timed out


-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

The terrorist and the policeman both come from the same basket.
	-- Joseph Conrad, The Secret Agent 
