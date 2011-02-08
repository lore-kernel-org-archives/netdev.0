From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Tue, 8 Feb 2011 13:34:08 -0800
Message-ID: <20110208133408.7d447e6a.akpm@linux-foundation.org>
References: <bug-28282-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, hadmut@danisch.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35101 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751945Ab1BHVef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 16:34:35 -0500
In-Reply-To: <bug-28282-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 5 Feb 2011 18:06:31 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=28282
> 
>            Summary: forwarding turns autoconfiguration off
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.35
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: hadmut@danisch.de
>         Regression: No
> 
> 
> Hi,
> 
> Linux ethernet interfaces do not use autoconfiguration and do ignore router
> advertisings if the packet forwarding is turned on in the configuration (i.e. 
> /proc/sys/net/ipv6/conf/eth0/forwarding set to 1)
> 
> 
> This might be wrong.
> 
> IPv6 network devices can have multiple IPv6 addresses and server several
> purposes at the same time. A machine can have a statically assigned local IPv6
> address and act as a router (e.g. to a virtual machine or a VPN tunnel) and
> thus needs to turn forwarding on, while at the same time it needs to listen to
> router advertisements and autoconfigure, e.g. because a network is connected to
> the internet through a DSL router with dynamically assigned network adresses,
> either through direct IPv6 assignment or a 6to4 tunnel. 
> 
> So there are cases where you need to have autoconfiguration of an IP address
> and forwarding on the same interface at the same time. Therefore, it might be
> technically wrong to have this mutually exclusive. 
> 

