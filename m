From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 194763] New: bond0 fails to accept MTU change.
Date: Thu, 2 Mar 2017 10:31:52 -0800
Message-ID: <20170302103152.59d0178e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36344 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751256AbdCBSkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 13:40:18 -0500
Received: by mail-pg0-f43.google.com with SMTP id s67so34893677pgb.3
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 10:39:27 -0800 (PST)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id s26sm18636373pge.33.2017.03.02.10.31.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Mar 2017 10:31:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 02 Mar 2017 11:22:24 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 194763] New: bond0 fails to accept MTU change.


https://bugzilla.kernel.org/show_bug.cgi?id=194763

            Bug ID: 194763
           Summary: bond0 fails to accept MTU change.
           Product: Networking
           Version: 2.5
    Kernel Version: 4.10.1
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: daznis@gmail.com
        Regression: No

Bond0 interface doesn't accept MTU higher than 1500.I can set MTU perfectly
fine for the slave devices. Recreating the bond0 didn't help to up the MTU. 



05:00.0 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+
Network Connection (rev 01)
05:00.1 Ethernet controller: Intel Corporation 82599ES 10-Gigabit SFI/SFP+
Network Connection (rev 01)

[ 1626.840818] bond0: Invalid MTU 9000 requested, hw max 1500
[ 1668.913497] ixgbe 0000:05:00.0 enp5s0f0: changing MTU from 1500 to 9000
[ 1669.176015] ixgbe 0000:05:00.0 enp5s0f0: speed changed to 0 for port
enp5s0f0
[ 1669.237523] ixgbe 0000:05:00.0 enp5s0f0: detected SFP+: 5
[ 1669.487920] ixgbe 0000:05:00.0 enp5s0f0: NIC Link is Up 10 Gbps, Flow
Control: RX/TX
[ 1675.591234] ixgbe 0000:05:00.1 enp5s0f1: changing MTU from 1500 to 9000
[ 1675.855232] ixgbe 0000:05:00.1 enp5s0f1: speed changed to 0 for port
enp5s0f1
[ 1675.911259] ixgbe 0000:05:00.1 enp5s0f1: detected SFP+: 6
[ 1676.159087] ixgbe 0000:05:00.1 enp5s0f1: NIC Link is Up 10 Gbps, Flow
Control: RX/TX
[ 1684.745389] bond0: Invalid MTU 9000 requested, hw max 1500




Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer3+4 (1)
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Min links: 0
Aggregator selection policy (ad_select): stable
System priority: 65535
System MAC address: 90:e2:ba:15:68:20
Active Aggregator Info:
        Aggregator ID: 2
        Number of ports: 2
        Actor Key: 13
        Partner Key: 221
        Partner Mac Address: 02:1c:73:b2:9a:29

Slave Interface: enp5s0f0
MII Status: up
Speed: 10000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 90:e2:ba:15:68:20
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: 90:e2:ba:15:68:20
    port key: 13
    port priority: 255
    port number: 1
    port state: 61
details partner lacp pdu:
    system priority: 32768
    system mac address: 02:1c:73:b2:9a:29
    oper key: 221
    port priority: 16000
    port number: 373
    port state: 61

Slave Interface: enp5s0f1
MII Status: up
Speed: 10000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 90:e2:ba:15:68:21
Slave queue ID: 0
Aggregator ID: 2
Actor Churn State: none
Partner Churn State: none
Actor Churned Count: 0
Partner Churned Count: 0
details actor lacp pdu:
    system priority: 65535
    system mac address: 90:e2:ba:15:68:20
    port key: 13
    port priority: 255
    port number: 2
    port state: 61
details partner lacp pdu:
    system priority: 32768
    system mac address: 02:1c:73:b2:9a:29
    oper key: 221
    port priority: 17000
    port number: 33141
    port state: 61

Settings for enp5s0f0:
        Supported ports: [ FIBRE ]
        Supported link modes:   1000baseT/Full 
                                10000baseT/Full 
        Supported pause frame use: Symmetric
        Supports auto-negotiation: Yes
        Advertised link modes:  1000baseT/Full 
                                10000baseT/Full 
        Advertised pause frame use: Symmetric
        Advertised auto-negotiation: Yes
        Speed: 10000Mb/s
        Duplex: Full
        Port: FIBRE
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes

Settings for enp5s0f1:
        Supported ports: [ FIBRE ]
        Supported link modes:   1000baseT/Full 
                                10000baseT/Full 
        Supported pause frame use: Symmetric
        Supports auto-negotiation: Yes
        Advertised link modes:  1000baseT/Full 
                                10000baseT/Full 
        Advertised pause frame use: Symmetric
        Advertised auto-negotiation: Yes
        Speed: 10000Mb/s
        Duplex: Full
        Port: FIBRE
        PHYAD: 0
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: d
        Wake-on: d
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: yes

-- 
You are receiving this mail because:
You are the assignee for the bug.
