From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Tue, 22 Jul 2008 03:48:50 -0700
Message-ID: <20080722034850.dbbc5566.akpm@linux-foundation.org>
References: <bug-11144-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: francois.valenduc@tvcablenet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33329 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbYGVKtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 06:49:17 -0400
In-Reply-To: <bug-11144-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 22 Jul 2008 03:21:33 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11144
> 
>            Summary: dhcp doesn't work with iwl4965
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26-git7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Wireless
>         AssignedTo: networking_wireless@kernel-bugs.osdl.org
>         ReportedBy: francois.valenduc@tvcablenet.be
> 
> 
> Latest working kernel version: 2.6.26-git6
> Earliest failing kernel version: 2.6.26-git7

A very fresh regression.

> Distribution: Gentoo
> Hardware Environment: Packard Bell MB86, iwl4965
> Software Environment: dhcpcd
> Problem Description: 
> I can't get an IP address via DHCP with my wireless connection. I have an Intel
> Wireless 4965 card and I use WPA personal with AES encryption. After a
> git-bisect run, it seems the first bad commit is the following:
> 
> commit 175f9c1bba9b825d22b142d183c9e175488b260c
> Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Date:   Sun Jul 20 00:08:47 2008 -0700
> 
>     net_sched: Add size table for qdiscs
> 
>     Add size table functions for qdiscs and calculate packet size in
>     qdisc_enqueue().
> 
>     Based on patch by Patrick McHardy
>      http://marc.info/?l=linux-netdev&m=115201979221729&w=2
> 
> 

A whole pile of networking patches went into mainline about 12 hours
ago, one of which might have fixed this.  Can you please test
2.6.26-git10 once it has appeared and let us know the result?


Thanks.
