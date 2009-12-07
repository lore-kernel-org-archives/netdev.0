From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few
 minutes of heavy surfing
Date: Mon, 7 Dec 2009 13:53:42 -0800
Message-ID: <20091207135342.6fb07264.akpm@linux-foundation.org>
References: <bug-14749-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, rankincj@yahoo.com,
	stable@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47726 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965068AbZLGVyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 16:54:49 -0500
In-Reply-To: <bug-14749-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 6 Dec 2009 13:40:18 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14749
> 
>            Summary: Kernel locks up after a few minutes of heavy surfing
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31.6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: rankincj@yahoo.com
>         Regression: Yes
> 
> 
> Created an attachment (id=24049)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24049)
> Warnings found in kernel, relating to network corruption.
> 
> This bug is new as of 2.6.31.x kernels. After a short period of heavy surfing
> (e.g. lots of tabs open in Firefox), the kernel will suddenly stop responding.
> Nothing is written to the serial console, and the machine stops responding to
> pings. My only clue so far has been a warning which I found once in my dmesg
> log (attached).
> 
> I have already tried manually applying this patch from the upcoming -stable
> queue:
> 
> net-fix-sk_forward_alloc-corruption.patch
> 
> to no effect.
> 
> I am currently switching back to Fedora's 2.6.31.6-145.fc12.i686 kernel to see
> if it is more stable. (I cannot trust 2.6.31.6 any more.)
> 

Thanks.

A regression in the latest 2.6.31 -stable tree.

Are you really really sure that you applied that patch, recompiled,
reinstalled, etc?
