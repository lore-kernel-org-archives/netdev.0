From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12772] New: linux is not able to handle more
 than ~4096 ipv6 addresses
Date: Tue, 24 Feb 2009 11:50:59 -0800
Message-ID: <20090224115059.807f5246.akpm@linux-foundation.org>
References: <bug-12772-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, tobias@linuxdingsda.de,
	yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40167 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755877AbZBXTvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 14:51:36 -0500
In-Reply-To: <bug-12772-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 24 Feb 2009 11:35:25 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12772
> 
>            Summary: linux is not able to handle more than ~4096 ipv6
>                     addresses
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26-1-amd64 #1 SMP Sat Jan 10 19:55:48 UTC 2009
>                     x86_64 GNU/Li

That's a fairly old kernel.

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: tobias@linuxdingsda.de
> 
> 
> Latest working kernel version: --
> Earliest failing kernel version: --
> Distribution: Debian sid
> Hardware Environment: model name      : Intel(R) Pentium(R) Dual  CPU  E2180  @
> 2.00GHz
> Software Environment: 
> Problem Description:
> Linux is unable to handle more than ~4096 ipv6 addresses and usually crashes
> after a not very long time. If not, it at least gets unusable slow.
> 
> Consider shared hosting environments, where you have some few thousand
> customers with a few domains each sitting on one box. You now would like to use
> ipv6 for greater fun with https and, for that, need about 6-30k addresses bound
> to the box.
> 
> 
> Steps to reproduce:
> 
> #!/bin/bash 
> COUNTER=1
> COUNTERR=1
> while [  $COUNTERR -lt 9999 ]; do
>         while [  $COUNTER -lt 9999 ]; do
>                 ip addr add 2001::$COUNTERR:$COUNTER/64 dev eth1
>                 let COUNTER=COUNTER+1
>                 echo $CONTERR $COUNTER
>         done
> let COUNTERR=COUNTER+1
> done
> 

