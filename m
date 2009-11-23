From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14677] New: multicast client application does
 not receive packets
Date: Mon, 23 Nov 2009 14:31:55 -0800
Message-ID: <20091123143155.412576d4.akpm@linux-foundation.org>
References: <bug-14677-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berndp@optonline.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48343 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754286AbZKWWbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:31:53 -0500
In-Reply-To: <bug-14677-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 23 Nov 2009 22:00:45 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14677
> 
>            Summary: multicast client application does not receive packets
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31.4-2.6.32-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: berndp@optonline.net
>         Regression: Yes
> 
> 
> When upgrading the kernel from 2.6.29.1 to 2.6.31.4, we discovered that packets
> no longer get delivered to an application that is subscribing to the multicast
> data.
> 
> We verified that multicast support was compiled into the kernel
> (CONFIG_IP_MULTICAST). A dump on the interface with tcpdump shows the multicast
> packets arriving on the network interface. However, they do not get delivered
> to the application.
> 
> /proc/net/igmp clearly showed that we were subscribed to the relevant multicast
> groups, and netstat showed that the application was listening.
> 
> Upgrading to 2.6.32-rc8 did not fix the problem, but downgrading to 2.6.29.1
> did.
> 
> This problem was seen on two different supermicro systems: one with a single
> (4-core) i7 940 Intel CPU, and another one with dual X5570 Xeon CPUS. In both
> cases the interface was on a quad-port NIC card 82571EB gigabit ethernet
> controller, rev 06.

