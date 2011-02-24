From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 29612] New: skge ipv6 doesn't work after boot
Date: Wed, 23 Feb 2011 16:21:56 -0800
Message-ID: <20110223162156.17ab2bc5.akpm@linux-foundation.org>
References: <bug-29612-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, gbillios@gmail.com,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58040 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126Ab1BXAWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 19:22:51 -0500
In-Reply-To: <bug-29612-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 21 Feb 2011 18:42:21 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=29612
> 
>            Summary: skge ipv6 doesn't work after boot
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.38-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: gbillios@gmail.com
>         Regression: No
> 
> 
> I have noticed that after the initial boot, ipv6 doesn't work until I either
> reconnect to the network with or do an ifdown/up cycle. 
> 
> The adapter has an ipv6 address, ipv6 routing table seems fine but there is no
> actual connectivity until I do what described above. During my debugging tries
> I noticed that ipv6 starts working also when I start capturing data with
> wireshark. If I enable promiscuous mode it starts working, if I start the
> capture *without* promiscuous mode it does nothing, as if the card needs a
> 'push' to start working. 
> 
> Here is the relevant skge output from dmesg, kernel version doesn't really
> matter since I have this issue even with earlier kernels. 
> 
> skge 0000:07:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> skge: 1.13 addr 0xf7ffc000 irq 16 chip Yukon-Lite rev 9
> skge 0000:07:01.0: eth0: addr 00:22:b0:e7:47:71
> skge 0000:07:01.0: eth0: enabling interface
> skge 0000:07:01.0: eth0: Link is up at 1000 Mbps, full duplex, flow control
> both
> skge 0000:07:01.0: eth0: disabling interface
> skge 0000:07:01.0: eth0: enabling interface
> skge 0000:07:01.0: eth0: Link is up at 1000 Mbps, full duplex, flow control
> both
> 
> Just to clarify, the ipv6 network setup is working just fine in general, other
> PCs on the network don't present this issue at all.

