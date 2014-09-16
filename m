From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: phy link status not stable
Date: Tue, 16 Sep 2014 21:56:56 +0530
Message-ID: <541864D0.7080803@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:43991 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032AbaIPQ1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 12:27:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

While doing ifdown/ifup test, phy link up status is very much delayed
and also link up/down comes alternatively without physical link changes
which leads to ifup failure. in v3.12 internal tree there is no failure.
Pasting the logs below.

root@am437x-evm:~# ifup eth0
[  652.633204] net eth0: initializing cpsw version 1.15 (0)
[  652.717428] net eth0: phy found : id is : 0x221622
udhcpc (v1.20.2) started
Sending discover...
Sending discover...
[  658.717859] cpsw 4a100000.ethernet eth0: Link is Up - 1Gbps/Full -
flow control rx/tx
Sending discover...
[  660.717894] cpsw 4a100000.ethernet eth0: Link is Down
[  661.717937] cpsw 4a100000.ethernet eth0: Link is Up - 1Gbps/Full -
flow control rx/tx
No lease, failing
root@am437x-evm:~# udhcpc
udhcpc (v1.20.2) started
Sending discover...
Sending select for 172.24.190.6...
Lease of 172.24.190.6 obtained, lease time 3600
/etc/udhcpc.d/50default: Adding DNS 192.0.2.2
/etc/udhcpc.d/50default: Adding DNS 192.0.2.3
root@am437x-evm:~#

Is this a known issue or any pointers where to look for clues?

Setup: TI-AM437x EVM
Phy: Micrel KSZ9031 Gigabit PHY

Thanks,
Mugunthan V N
