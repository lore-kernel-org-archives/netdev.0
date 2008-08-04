From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11249] New: TC HTB hanging problem
Date: Mon, 4 Aug 2008 10:55:06 -0700
Message-ID: <20080804105506.8b401320.akpm@linux-foundation.org>
References: <bug-11249-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, lansoweb@hotmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51723 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269AbYHDRzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 13:55:32 -0400
In-Reply-To: <bug-11249-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon,  4 Aug 2008 08:01:05 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11249
> 
>            Summary: TC HTB hanging problem
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23 and 2.6.25
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: lansoweb@hotmail.com
> 
> 
> Latest working kernel version:
> Earliest failing kernel version: 2.6.23
> 
> Distribution: Mandriva 2007.1 and 2008.0
> 
> Hardware Environment:
> It happens in many different servers
> 
> Software Environment:
> Problem Description:
> I have close to 200 servers, most with mandriva 2006.0 using kernel 2.6.15,
> some with mandriva 2008.0 using kernel 2.6.23 or 2.6.25. In some of them
> (kernels 2.6.23 and 2.6.25 confirmed) the server hangs at random (some servers
> hang more than once a day, some once a month).
> The hardware is different from each other and i have about 5 servers with
> exactly the same configuration (proc, mem, ethernet, so one) and one hangs
> every day while the others are running fine, all with the same rules for
> traffic shapping (tc using htb).
> I think that it is something related to tc because last week i accessed a
> server and when i type tc del to remove the shapping it hanged. My client
> restarted the server and about 10 minutes later i did it again with the same
> effect. No kernel panic, no oops, just hangs. 
> I've read some posts and bugs but i see something related to ethernet driver
> (like sk98lin), but it is happening with several servers with different
> hardwares.
> I have some servers with kernel 2.6.15 and, as far as i know, it doesn't happen
> with them, but some of they use a different set of tc rules (a few less rules
> actually) or none at all.
> I don't use the kernel shippied with mandriva distro, always got kernel from
> kernel.org and compilled myself.
> 
> Steps to reproduce:
> Handly, since it is random, it takes minutes or weeks to happen, but always
> with some change in tc (start or stop).

