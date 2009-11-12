From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14586] New: bridge on bonding interface: DHCP
 replies don't get through
Date: Thu, 12 Nov 2009 14:39:13 -0800
Message-ID: <20091112143913.3d89e4f4.akpm@linux-foundation.org>
References: <bug-14586-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	harald.dunkel@t-online.de
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59094 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754718AbZKLWjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 17:39:11 -0500
In-Reply-To: <bug-14586-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 11 Nov 2009 14:28:00 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14586
> 
>            Summary: bridge on bonding interface: DHCP replies don't get
>                     through
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: harald.dunkel@t-online.de
>         Regression: No
> 
> 
> I would like to run a bridge for kvm on a bonding interface (4 * 1Gbit, Intel
> e1000e). Problem: The DHCPDISCOVER packets sent by the guest show up on my dhcp
> server as expected, but the DHCPOFFER sent as a reply doesn't reach the guest
> behind the bridge.
> 
> Using tcpdump on host and guest I can see the DHCPOFFER on the bond0 and br0
> interface, but it never shows up on vnet0 or on the guest's eth0.
> 
> If I drop the bonding interface and use the host's eth2 for the bridge instead,
> then there is no such problem.
> 
> Kernel on host and guest is 2.6.31.5. Attached you can find more information
> about my setup. 
> 
> I had sent this information to the linux kvm mailing list before, but consensus
> was that this is a bridging problem. See
> 
>     http://www.spinics.net/lists/kvm/msg25153.html
> 
> There was no reply on the linux bridge mailing list, see 
> 
>    
> https://lists.linux-foundation.org/pipermail/bridge/2009-November/006749.html

