From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10283] New: Ooops when bonding and vlan on the
 same device
Date: Wed, 19 Mar 2008 14:00:56 -0700
Message-ID: <20080319140056.4eff6571.akpm@linux-foundation.org>
References: <bug-10283-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	amartins@crefidis.fr
To: Jay Vosburgh <fubar@us.ibm.com>,
	Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58347 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965543AbYCSVHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:07:06 -0400
In-Reply-To: <bug-10283-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switching to email - please respond via emailed reply-to-all, not via the
bugzilla web interface)

On Wed, 19 Mar 2008 05:19:34 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10283
> 
>            Summary: Ooops when bonding and vlan on the same device
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.18
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: amartins@crefidis.fr
> 
> 
> Latest working kernel version: ?
> Earliest failing kernel version: 2.6.18-6
> Distribution: Debian
> Hardware Environment: x86-686
> Software Environment: stable release of Debian ETCH
> Problem Description:
> 
> Ooops when adding a vlan on a device that is in slave mode of a bond device
> (Sory for my english :)
> 
> Steps to reproduce:
> 
> modprobe bonding mode=1 miimon=100
> ifconfig eth0 promisc up
> ifenslave bond0 eth0
> ifconfig bond0 up
> vconfig add eth0 2 => Ooops
> 

Is a copy of the oops output available?

Is there any possibility of testing a more up-to-date kernel?

Thanks.
