From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14007] New: iproute2: socket lookup after
 policy-based local route returns "connect: Invalid argument"
Date: Thu, 20 Aug 2009 14:36:18 -0700
Message-ID: <20090820143618.fae0d200.akpm@linux-foundation.org>
References: <bug-14007-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, markus@selfnet.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36746 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751156AbZHTVgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 17:36:52 -0400
In-Reply-To: <bug-14007-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 19 Aug 2009 08:55:44 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14007
> 
>            Summary: iproute2: socket lookup after policy-based local route
>                     returns "connect: Invalid argument"
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: markus@selfnet.de
>         Regression: No
> 
> 
> I want to add policy based routes to my local machine similar to the iptables
> redirect command. With this it is possible to redirect connections without
> losing the destination ip.
> So i tried to add an route of type local to another routing table then table
> local:
> 
> sudo ip route add local 192.168.33.0/24 dev eth0 table local
> ping 192.168.33.1 -c 1
> #working
> 
> sudo ip route add local 192.168.34.0/24 dev eth0 table main
> ping 192.168.34.1 -c 1
> #connect: Invalid argument
> 
> The first one is working, the secound one not. The only difference is another
> routing table. icmp is only an example, tcp and udp doesnt work neither.
> 
> I guess somewhere in the socketlookup linux checks the destination ip with the
> local routes only in the local table. perhaps the other tables are missed.
> 
> btw: i tried it on every linux with iproute2 i found. with no succeed
> 

