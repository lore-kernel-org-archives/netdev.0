From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9661] New: Booting from nfsroot fails
Date: Sat, 29 Dec 2007 15:14:01 -0800
Message-ID: <20071229151401.ee32b8f7.akpm@linux-foundation.org>
References: <bug-9661-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Simon Horman <horms@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>
To: bugs@psycast.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57445 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752500AbXL2XP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 18:15:58 -0500
In-Reply-To: <bug-9661-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Dec 2007 11:54:07 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9661
> 
>            Summary: Booting from nfsroot fails
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc6-git4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: bugs@psycast.de
> 
> 
> Most recent kernel where this bug did not occur: 2.6.24-rc6-git3
> Distribution: Debian GNU Linux 4.0/Etch
> Hardware Environment: Intel DG965SS, 4GB RAM, onboard e1000, no HDD
> Software Environment: Debian GNU Linux 4.0r2 x86_64
> Problem Description: Starting with -git4 release the System won't boot from
> network. Booting with root=/dev/nfs ip=dhcp for example ends in asking the user
> to insert a boot floppy. This is obviously not the expected result when booting
> from network. 
> 
> The cause seem to be the changeset a6c05c3d064dbb83be88cba3189beb5db9d2dfc3.
> Looking at the code I found that ic_enable doesn't get set as expected. This
> prevents the kernel from initializing the ip configuration. 
> 
> The patch & my LK conf (for reference) are attached. This may be not the ideal
> way of solving this, there are probably better ones. This one "Works For Me" :)

Thanks for the fix, but please send patches via email and not via bugzilla?

Suitable recipients for this one would be

netdev@vger.kernel.org
Simon Horman <horms@verge.net.au>
"David S. Miller" <davem@davemloft.net>
