From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11447] New: /proc/sys/net/ipv4/route/flush not
 found
Date: Thu, 28 Aug 2008 13:18:24 -0700
Message-ID: <20080828131824.49352fa0.akpm@linux-foundation.org>
References: <bug-11447-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: francois.valenduc@tvcablenet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57618 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753315AbYH1USc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:18:32 -0400
In-Reply-To: <bug-11447-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 28 Aug 2008 11:06:22 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11447
> 
>            Summary: /proc/sys/net/ipv4/route/flush not found
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27-rc4-git7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: francois.valenduc@tvcablenet.be
> 
> 
> Latest working kernel version: 2.6.27-rc4
> Earliest failing kernel version: probably 2.6.27-rc4-git7
> Distribution: Gentoo
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> When the lo interface is initialized, the following error occurs:
> can't open /proc/sys/net/ipv4/route/flush: no such file.
> After a bisection, it appears that the following commit is the first bad
> commit:
> 
> commit 2f4520d35d89ca6c5cd129c38e3b11f0283b7d1b
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Mon Aug 25 15:17:44 2008 -0700
> 
>     ipv4: sysctl fixes
> 
>     net.ipv4.neigh should be a part of skeleton to avoid ordering problems
> 
>     Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> If I revert it, the problem doesn't occur.
> 
> 

