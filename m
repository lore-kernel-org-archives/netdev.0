From: Antonio Gallo <agx@linux.it>
Subject: r8169, broken supported ports FIBRE
Date: Tue, 23 Sep 2008 11:32:38 +0200
Message-ID: <48D8B7B6.3020108@linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: shuchen@realtek.com.tw, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpd4.aruba.it ([62.149.128.209]:44838 "HELO smtp3.aruba.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751459AbYIWJcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 05:32:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On this card using the r8169:

Device: 02:00.0
Class:  0200
Vendor: 10ec
Device: 8168
SVendor:        1458
SDevice:        e000
Rev:    02

I've a strange problem. No kernel messages but the card is functioning 
only for a few second every 20 seconds.
Ethtool reported the card as connected using the FIBRE port at 1000 
speed as available only.

Settings for eth0:
        Supported ports: [ FIBRE ]
        Supported link modes:   1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  Not reported
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: FIBRE
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000033 (51)
        Link detected: yes

I tried both ethtool v5 and v6 to change card port from fibre to tp or 
mii and from 1000 to 100 or 10 but
everytime it says card is not supported.

I've also tried all the fancy kernel parameters about msi, acpi, apic, 
apm, etc.

Should i try the r8168.ko from the realtek web site instead of the 
kernel module r8169 ?

