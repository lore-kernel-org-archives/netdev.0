From: Robert Grasso <robert.grasso@modulonet.fr>
Subject: driver r8169 suddenly failed
Date: Mon, 26 Dec 2016 09:01:43 +0100
Message-ID: <428aa40c-e313-99ae-d3ae-97b6a5ef40e4@modulonet.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.tech.numericable.fr ([82.216.111.39]:58968 "EHLO
        smtp3.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbcLZIKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 03:10:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am a senior Linux sysadmin.
At home, I am using a Shuttle DS47 barebones computer as my firewall; it 
contains the following two network cards :
01:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8188CE 
802.11b/g/n WiFi Adapter (rev 01)
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 0c)

04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 0c)

The OS is Ubuntu 14.04.5 LTS with kernel 3.13.0-101-generic. The kernel 
has been using the driver r8169 successfully from the very first 
installation (2 or 3 years ago).

The first NIC is connected onto my french provider's (Numericable) cable 
modem Netgear CBVG834G
The second NIC goes to my LAN.

Last friday, suddenly, the connection to the cable modem failed. From 
that moment, acquiring a DHCP address fails always, the request is 
looping endlessly :

DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 3 (xid=0x7da87c44)
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 3 (xid=0x7da87c44)
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 5 (xid=0x7da87c44)
DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 6 (xid=0x7da87c44)
(...)

I tried to boot the Shuttle from an USB dongle with Ubuntu 16.04 : the 
connection failed in the same way.

My Ubuntu 16 laptop (a brand new Dell XPS)  connects successfully on the 
cable modem (through Ethernet - by choice, no wireless at my home). 
Also, I am using a cheap Ethernet-to-USB converter connected on the 
Shuttle and on the cable modem in order to get a temporary Internet 
access - this allows me to send this email.

I am using dhclient.

I just installed r8168-dkms_8.043.02-1_all.deb, but this does not fix 
the issue.

I assume that my ISP upgraded something in the cable modem.

First of all, can you confirm that I am doing right in posting to you 
(addresses found in README.Debian) ?

If I do, can you help ? I am not very proficient with Ethernet, and I am 
not able to figure out what my provider changed : their hotline is 
underqualified, they are just able to tell that "the signal on the line 
is ok". But if you want me to run various tests, try new versions, I 
would be glad to do so : I would appreciate if I could salvage this Shuttle.

Best regards

-- 
Robert Grasso
@home
---
UNIX was not designed to stop you from doing stupid things, because
   that would also stop you from doing clever things. -- Doug Gwyn
