From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: netconsole on bnx2 not working?
Date: Sun, 20 Jan 2008 17:54:31 +0200
Message-ID: <20080120154119.M46441@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:49062 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662AbYATPyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 10:54:51 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 23F82BC821
	for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 17:54:31 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am trying to run netconsole on Dell PowerEdge 1950, equipped with two
Broadcom NIC, without any success.

Tried to load netconsole on eth1 and eth0 (interface was renamed by udev), and
after that i am loading ppp_generic (which generate some data in kernel log).
Watching by tcpdump on remote, and local host - nothing is shown there.

The same time i am testing on RTL8139, same commands(just ip/mac different,
and sure machine is different) work fine.

Is any specific reason for that here? How i can debug this issue?
Do i need to enable netpoll for that?

I tried to create target over configfs, without any luck. Still no data is sent.

visp-1 test # pwd
/config/netconsole/test
visp-1 test # ls
dev_name  enabled  local_ip  local_mac  local_port  remote_ip  remote_mac 
remote_port
visp-1 test # grep "" *
dev_name:eth0
enabled:1
local_ip:217.151.X.Y
local_mac:00:13:72:f8:73:ac
local_port:6665
remote_ip:217.151.X.X
remote_mac:00:30:48:90:09:06
remote_port:514


dmesg
[537625.200501] Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.6.9
(December 8, 2007)
[537625.200888] ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) ->
IRQ 16
[537625.531219] eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X
64-bit 133MHz found at mem f4000000, IRQ 16, node addr 00:13:72:f8:73:ae
[537625.531268] ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) ->
IRQ 16
[537625.532352] udev: renamed network interface eth0 to eth1
[537625.888397] eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X
64-bit 133MHz found at mem f8000000, IRQ 16, node addr 00:13:72:f8:73:ac

dmesg on loading netconsole on eth0 and eth1
[538036.561776] netconsole: local port 111
[538036.561785] netconsole: local IP 217.151.X.X
[538036.561789] netconsole: interface eth1
[538036.561793] netconsole: remote port 514
[538036.561802] netconsole: remote IP 217.151.X.X
[538036.561808] netconsole: remote ethernet address 00:30:48:90:09:06
[538036.565989] console [netcon0] enabled
[538036.565998] netconsole: network logging started

[537899.157053] netconsole: couldn't parse config at 217.151.224.117!
[537899.157064] netconsole: cleaning up
[537942.772496] netconsole: local port 111
[537942.772505] netconsole: local IP 217.151.X.X
[537942.772510] netconsole: interface eth0
[537942.772514] netconsole: remote port 514
[537942.772518] netconsole: remote IP 217.151.X.X
[537942.772549] netconsole: remote ethernet address 00:30:48:90:09:06
[537942.780203] console [netcon0] enabled
[537942.780213] netconsole: network logging started




--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

