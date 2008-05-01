From: Ben Greear <greearb@candelatech.com>
Subject: brctl shows output for pegasus ethernet device?
Date: Thu, 01 May 2008 15:55:44 -0700
Message-ID: <481A4A70.1040806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:57955 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbYEAX0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 19:26:14 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m41MtixU014894
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 1 May 2008 15:55:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was expecting brctl to fail in this case, but it shows data
for the pegasus USB ethernet device??

brctl version 1.2  (FC8)
kernel 2.6.25 plus hacks


[root@eepc ]# brctl showstp eth3
eth3
  bridge id              0000.000018000000
  designated root        0200.000004000000
  root port               255                    path cost               7664
  max age                   0.00                 bridge max age             0.00
  hello time                0.00                 bridge hello time          0.00
  forward delay             0.00                 bridge forward delay       0.00
  ageing time               0.00
  hello timer               0.00                 tcn timer               11346042.76
  topology change timer  32183585.20                     gc timer                32183588.56
  flags                  TOPOLOGY_CHANGE TOPOLOGY_CHANGE_DETECTED


[root@eepc ]# ethtool eth3
Settings for eth3:
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
         PHYAD: 1
         Transceiver: internal
         Auto-negotiation: on
         Supports Wake-on: pg
         Wake-on: d
         Current message level: 0x00000007 (7)
         Link detected: yes
[root@eepc ]# ethtool -i eth3
driver: pegasus
version: v0.6.14 (2006/09/27)
firmware-version:
bus-info: usb-0000:00:10.0-2


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

