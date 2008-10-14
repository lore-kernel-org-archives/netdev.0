From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Tue, 14 Oct 2008 05:32:36 -0700
Message-ID: <20081014053236.69a71a2f.akpm@linux-foundation.org>
References: <bug-11754-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, mostrows@earthlink.net,
	Manfred.Scherer.Mhm@t-online.de,
	Robert Fitzsimons <robfitz@273k.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48321 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756066AbYJNMdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 08:33:50 -0400
In-Reply-To: <bug-11754-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

> On Mon, 13 Oct 2008 15:26:04 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=11754
> 
>            Summary: tlan network driver does not work
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: Manfred.Scherer.Mhm@t-online.de
> 
> 
> Latest working kernel version: 2.6.26
> Earliest failing kernel version: 2.6.27

A 2.6.27 regression.

Not much has happened in tlan.c - a single fix from Robert.  This
regression might be in pppoe?


> Distribution: SuSE 9.2
> Hardware Environment:
> /var/log/boot.msg:
> <6>ThunderLAN driver v1.15
> <6>tlan 0000:00:0d.0: found PCI INT A -> IRQ 11
> <6>tlan 0000:00:0d.0: sharing IRQ 11 with 0000:00:09.0
> <6>TLAN: eth1 irq=11, io=c400, Compaq Netelligent 10/100 TX PCI UTP, Rev. 16
> <6>TLAN: 1 device installed, PCI: 1  EISA: 0
> ...
> Setting up network interfaces:
>     lo
>     lo        IP address: 127.0.0.1/8
> done    eth0      device: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
>     eth0      configuration: eth-id-52:54:00:db:15:ff
>     eth0      IP address: 192.168.0.99/24
> done    eth1      device: Compaq Computer Corporation Compaq Netelligent 10/100
> TX PCI UTP TLAN 2.3 (rev 10)
>     eth1      IP address: 192.168.1.22/24
> done    dsl0
>     dsl0      Startmode is 'manual'
> 
> 
> Software Environment:
> 
> Problem Description:
> 
> PPPoe does not work
> see /var/log/messages:
> 
> Oct 13 14:39:06 pc1 pppd[10123]: Plugin rp-pppoe.so loaded.
> Oct 13 14:39:06 pc1 kernel: PPP generic driver version 2.4.2
> Oct 13 14:39:06 pc1 pppd[10123]: RP-PPPoE plugin version 3.3 compiled against
> pp
> pd 2.4.2
> Oct 13 14:39:06 pc1 pppd[10123]: Plugin passwordfd.so loaded.
> Oct 13 14:39:06 pc1 kernel: NET: Registered protocol family 17
> Oct 13 14:39:06 pc1 pppd[10123]: pppd 2.4.2 started by root, uid 0
> Oct 13 14:39:41 pc1 pppd[10123]: Timeout waiting for PADO packets
> Oct 13 14:39:41 pc1 pppd[10123]: Unable to complete PPPoE Discovery
> Oct 13 14:39:41 pc1 pppd[10123]: Exit.
> 
> 
> Steps to reproduce:
> 
> start dsl-connection to internet.
> 

