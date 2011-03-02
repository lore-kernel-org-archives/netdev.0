From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30082] New: after lxc-stop:
 unregister_netdevice: waiting for lo to become free. Usage count: 3
Date: Tue, 1 Mar 2011 16:13:50 -0800
Message-ID: <20110301161350.108f6c83.akpm@linux-foundation.org>
References: <bug-30082-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mjt@tls.msk.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50378 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756799Ab1CBAOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 19:14:16 -0500
In-Reply-To: <bug-30082-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 28 Feb 2011 14:47:03 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30082
> 
>            Summary: after lxc-stop: unregister_netdevice: waiting for lo
>                     to become free. Usage count: 3
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.36 2.6.37
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: mjt@tls.msk.ru
>         Regression: No
> 
> 
> As far as I can tell so far this is triggered by lxc version 0.7.4, at least I
> haven't seen this before.  I tried 2.6.36[.3] and 2.6.37[.2] kernels so far,
> both behaves similarly.
> 
> The problem is, when I shut down a container which uses bridged veth interface
> pair using lxc-stop, the container terminates, but host system starts crying
> about unregister_netdevice like this:
> 
> [902885.096462] unregister_netdevice: waiting for lo to become free. Usage
> count = 3
> [902895.229785] unregister_netdevice: waiting for lo to become free. Usage
> count = 3
> [...]
> [904247.123002] unregister_netdevice: waiting for lo to become free. Usage
> count = 3
> 
> After some, random, time, this stops - sometimes after just one message,
> sometimes after several minutes.  Sometimes it does not happen at all.
> 
> This looks like a kernel issue triggerable by lxc-0.7.4.
> 

