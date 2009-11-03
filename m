From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14431] New: atl1 eth0 link continuously down
 up
Date: Mon, 2 Nov 2009 22:40:18 -0800
Message-ID: <20091102224018.e306b12f.akpm@linux-foundation.org>
References: <bug-14431-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, johan_vdp@hotmail.com
To: atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46453 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752147AbZKCGke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 01:40:34 -0500
In-Reply-To: <bug-14431-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 17 Oct 2009 19:17:38 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14431
> 
>            Summary: atl1 eth0 link continuously down up
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.30.8-64.fc11.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: johan_vdp@hotmail.com
>         Regression: No
> 
> 
> /var/log/messages shows
> ..
> Oct 17 21:06:01 blauw kernel: atl1 0000:01:00.0: eth0 link is down
> Oct 17 21:06:01 blauw kernel: atl1 0000:01:00.0: eth0 link is up 100 Mbps full
> duplex
> Oct 17 21:06:02 blauw kernel: atl1 0000:01:00.0: eth0 link is down
> Oct 17 21:06:02 blauw kernel: atl1 0000:01:00.0: eth0 link is up 100 Mbps full
> duplex
> Oct 17 21:06:02 blauw kernel: atl1 0000:01:00.0: eth0 link is down
> Oct 17 21:06:02 blauw kernel: atl1 0000:01:00.0: eth0 link is up 100 Mbps full
> duplex
> ..
> This behavior is also shown on another machine (same motherboard, other
> devices), running another kernel.
> ..
> Oct 17 20:47:03 localhost kernel: atl1 0000:01:00.0: Unable to enable MSI: -22
> Oct 17 20:47:03 localhost kernel: atl1 0000:01:00.0: eth0 link is up 100 Mbps
> full duplex
> Oct 17 20:47:06 localhost kernel: atl1 0000:01:00.0: eth0 link is down
> Oct 17 20:47:22 localhost kernel: atl1 0000:01:00.0: eth0 link is up 100 Mbps
> full duplex
> ..
> 
> Using other ethernet wires or using a older hub instead of a switch does not
> solve this issue. Each PC attached individually to hub/switch shows the same
> behavior.
> 
> As the logs mention MSI, I have tried to disable MSI using kernel boot option
> pci=nomsi to no avail.
> 
> I have posted the same bug at Fedora, but followup stopped.
> https://bugzilla.redhat.com/show_bug.cgi?id=527101
> 
> Any suggestions or questions? I will try to help where I can.

