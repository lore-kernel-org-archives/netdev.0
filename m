From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11160] New: sky2 Oops on ifconfig eth0 down on
 linux-2.6.26-git11
Date: Fri, 25 Jul 2008 01:27:54 -0700
Message-ID: <20080725012754.c130a09e.akpm@linux-foundation.org>
References: <bug-11160-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, jkarlson@cc.hut.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54520 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751773AbYGYI17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 04:27:59 -0400
In-Reply-To: <bug-11160-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 25 Jul 2008 01:19:16 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11160
> 
>            Summary: sky2 Oops on ifconfig eth0 down on linux-2.6.26-git11

(it's a warning, not an oops)

>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.26-git11
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: jkarlson@cc.hut.fi
> 
> 
> Latest working kernel version: linux-2.6.26-git9
> Earliest failing kernel version: linux-2.6.26-git11
> Distribution: gentoo
> Hardware Environment: macbook revision 2
> Problem Description:
> ------------[ cut here ]------------
> WARNING: at net/core/dev.c:1344 __netif_schedule+0x24/0x6d()
> Modules linked in: coretemp hwmon i2c_i801 sky2
> Pid: 3198, comm: ifconfig Not tainted 2.6.26-git11 #1
> 
> Call Trace:
>  [<ffffffff8022eb69>] warn_on_slowpath+0x51/0x8c
>  [<ffffffff80240459>] autoremove_wake_function+0x9/0x2e
>  [<ffffffff80226550>] __wake_up_common+0x46/0x76
>  [<ffffffff802273b3>] __wake_up+0x38/0x4e
>  [<ffffffff804d163e>] __netif_schedule+0x24/0x6d
>  [<ffffffffa0003a40>] sky2_down+0x367/0x433 [sky2]
>  [<ffffffff804df797>] some_qdisc_is_running+0x4e/0x6e
>  [<ffffffff804d3a62>] dev_close+0x69/0x88
>  [<ffffffff804d374a>] dev_change_flags+0xa6/0x163
>  [<ffffffff80509fe4>] devinet_ioctl+0x268/0x5c4
>  [<ffffffff80285799>] __user_walk_fd+0x48/0x53
>  [<ffffffff804c791a>] sock_ioctl+0x1eb/0x20f
>  [<ffffffff80286d99>] vfs_ioctl+0x21/0x6c
>  [<ffffffff8028700b>] do_vfs_ioctl+0x227/0x23d
>  [<ffffffff8028705e>] sys_ioctl+0x3d/0x5f
>  [<ffffffff8020b20b>] system_call_fastpath+0x16/0x1b
> 
> ---[ end trace a64966769ce52dec ]---
> 
> 
> Steps to reproduce: ifconfig eth0 down
> 
> This is also the first kernel version I tried with ath9k (which btw works), it
> may or may not have some influence on this, will try later.
> 

I think this is known about and is being worked on.
