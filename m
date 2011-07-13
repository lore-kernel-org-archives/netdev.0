From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 39252] New: [r8169] PPPoE connections don't
 work if a custom MAC address is assigned
Date: Wed, 13 Jul 2011 16:13:45 -0700
Message-ID: <20110713161345.82e254de.akpm@linux-foundation.org>
References: <bug-39252-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, t.artem@mailcity.com,
	Michal Ostrowski <mostrows@earthlink.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58040 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752109Ab1GMXNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 19:13:55 -0400
In-Reply-To: <bug-39252-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 12 Jul 2011 22:51:16 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=39252
> 
>            Summary: [r8169] PPPoE connections don't work if a custom MAC
>                     address is assigned
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: t.artem@mailcity.com
>         Regression: No
> 
> 
> Description of problem: if I assign a custom MAC address to my onboard NIC,
> then I cannot establish PPPoE connections, and even `pppoe -A` command doesn't
> return any PPPoE access concentrators.
> 
> 
> Version-Release number of selected component (if applicable): r8169 2.3LK-NAPI
> 
> 
> How reproducible: always
> 
> 
> Steps to Reproduce:
> 1. Boot
> 2. ifconfig eth0 hw ether MACADDRESS
> 3. Try to establish PPPoE connection using eth0
> 
> Actual results: PPPoE connection cannot be established, no network packets
> return
> 
> 
> Expected results: PPPoE connections working
> 
> 
> Additional info: if I put eth0 in the promiscuous mode, then PPPoE starts
> working.
> 
> Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express
> Gigabit Ethernet controller (rev 06)
>         Subsystem: ASUSTeK Computer Inc. Device 8432
>         Flags: bus master, fast devsel, latency 0, IRQ 47
>         I/O ports at e000 [size=256]
>         Memory at d0004000 (64-bit, prefetchable) [size=4K]
>         Memory at d0000000 (64-bit, prefetchable) [size=16K]
>         Capabilities: [40] Power Management version 3
>         Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Capabilities: [70] Express Endpoint, MSI 01
>         Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
>         Capabilities: [d0] Vital Product Data
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [140] Virtual Channel
>         Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
>         Kernel driver in use: r8169
>         Kernel modules: r8169
> 

