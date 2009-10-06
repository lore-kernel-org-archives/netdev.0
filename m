From: Stephen Hemminger <shemminger@vyatta.com>
Subject: alt1c: ethernet driver bug
Date: Tue, 6 Oct 2009 16:10:48 -0700
Message-ID: <20091006161048.6b52b6be@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56797 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933292AbZJFXLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 19:11:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> http://bugzilla.kernel.org/show_bug.cgi?id=14336
> 
>            Summary: [Pardus] Soft Lockup Problem with Attansic Ethernet
>                     Card
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30.8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: badibere@gmail.com
>         Regression: No
> 
> 
> I have soft lockup problem with attansic ethernet card while activating eth0
> interface.
> 
> My ethernet card is 09:00.0 Ethernet controller: Attansic Technology Corp.
> Device 1063 (rev c0)
> 
> If I try to activate eth0 interface while network cable is pluged in, then
> everything freezes.
> 
> If I try to activate eth0 interface while network cable isn't pluged in, then
> no problem. But, if i plug in, again freezes.
> 
> My /var/log/syslog is in attachment.
> 

this is what was in the bug attachment

Oct  7 00:53:33 baDibere kernel: [   16.162099] atl1c 0000:09:00.0: enabling device (0000 -> 0002)
Oct  7 00:53:33 baDibere kernel: [   16.162117] atl1c 0000:09:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
Oct  7 00:53:33 baDibere kernel: [   16.162141] atl1c 0000:09:00.0: setting latency timer to 64
Oct  7 00:53:33 baDibere kernel: [   16.162247] atl1c 0000:09:00.0: PME# disabled
Oct  7 00:53:33 baDibere kernel: [   16.162266] atl1c 0000:09:00.0: PME# disabled
Oct  7 00:53:33 baDibere kernel: [   16.230835] atl1c 0000:09:00.0: version 1.0.0.1-NAPI
Oct  7 00:55:57 baDibere kernel: [  169.943463] atl1c 0000:09:00.0: Unable to allocate MSI interrupt Error: -22
Oct  7 00:55:57 baDibere kernel: [  169.943576] atl1c 0000:09:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full Duplex>
