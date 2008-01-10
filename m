From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9721] New: wake on lan fails with sky2 module
Date: Wed, 9 Jan 2008 16:03:00 -0800
Message-ID: <20080109160300.304ec687.akpm@linux-foundation.org>
References: <bug-9721-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, supersud501@yahoo.de
To: netdev@vger.kernel.org, linux-acpi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34122 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753995AbYAJADE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 19:03:04 -0500
In-Reply-To: <bug-9721-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed,  9 Jan 2008 13:05:34 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9721
> 
>            Summary: wake on lan fails with sky2 module
>            Product: ACPI
>            Version: 2.5
>      KernelVersion: 2.6.24-rc7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Power-Sleep-Wake
>         AssignedTo: acpi_power-sleep-wake@kernel-bugs.osdl.org
>         ReportedBy: supersud501@yahoo.de

This post-2.6.23 regression was assigned to ACPI but is quite possibly a
net driver problem?

> 
> Latest working kernel version: 2.6.23.12
> Earliest failing kernel version: 2.6.24-rc6 (not tested earlier kernel,
> 2.6.24-rc7 still failing)
> Distribution: Ubuntu 8.04 (but Kernel build from Kernel.org and system modifiet
> to make wake on lan work, i.e. network cards are not shutted down on poweroff)
> Hardware Environment: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit
> Ethernet Controller (rev 20) onboard Asus P5W DH motherboard, uses module SKY2
> Software Environment:
> Problem Description:
> 
> When enabling wake on lan with: 'ethtool -s eth0 wol' i get the following
> status:
> 
> 21:56:29 ~ # sudo ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Half 1000baseT/Full 
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full 
>                                 100baseT/Half 100baseT/Full 
>                                 1000baseT/Half 1000baseT/Full 
>         Advertised auto-negotiation: Yes
>         Speed: 100Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: pg
>         Wake-on: g    <---- wol enabled
>         Current message level: 0x000000ff (255)
>         Link detected: yes
> 
> but after shutting down the pc doesn't wake up when magic packet is sent.
> 
> the status lights of the network card are still on (so the card seems to be
> online).
> 
> same system with only changed kernel to 2.6.23.12 and same procedure like
> above: wake on lan works.
> 
> Steps to reproduce: enable wol on your network card using SKY2 module and it
> doesn't work too?
> 
> if you need more information, just tell me, it's my first bug report.
> regards
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
