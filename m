From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30462] New: High cpu usage when someone sends
 many ipv6 udp packages
Date: Fri, 4 Mar 2011 17:15:06 -0800
Message-ID: <20110304171506.0e27cde1.akpm@linux-foundation.org>
References: <bug-30462-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ernstp@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55978 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760343Ab1CEBQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 20:16:21 -0500
In-Reply-To: <bug-30462-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 5 Mar 2011 01:10:53 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30462
> 
>            Summary: High cpu usage when someone sends many ipv6 udp
>                     packages
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38-rc3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: ernstp@gmail.com
>         Regression: Yes
> 
> 
> Hi,
> 
> while testing ipv6 performance on my local network I found the following
> problem.
> When sending lots of UDP packages over ipv6 to a machine running kernel
> 2.6.38-rc3 or later that machines become heavily loaded and X may stop
> responding for long periods of time for example, sound skips etc.
> A ksoftirqd and kworker thread each run 100% on my machine.
> 
> I'm using this command to trigger this:
> iperf -c fe80::21f:d0ff:fe54:1ad4%eth0 -b 1000M -u -V
> You _don't_ have to setup an iperf server on the reciever.
> 
> I have a gigabit network with a WNDR3700 with the new V1.0.7.98 firmware that's
> "IPv6 ready".
> 
> I've used the kernels from http://kernel.ubuntu.com/~kernel-ppa/mainline/ to
> narrow down that this happens with 2.6.38-rc3 and later but not with 2.6.38-rc2
> and earlier like 2.6.37 and 2.6.35.
> 
> The following ipv6 related changes were introduced between -rc2 and -rc3 that I
> can see. The "Revert 'administrative down' address handling changes." looked
> big...
>       ipv6: Always clone offlink routes.
>       ipv6: Revert 'administrative down' address handling changes.
> 

