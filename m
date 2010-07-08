From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16350] New: RTL8103EL interface new tcp
 connections get stuck on SYN_SENT state after 10 hours uptime
Date: Thu, 8 Jul 2010 14:25:26 -0700
Message-ID: <20100708142526.5bf5938e.akpm@linux-foundation.org>
References: <bug-16350-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>, zic422@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46243 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756874Ab0GHV1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 17:27:06 -0400
In-Reply-To: <bug-16350-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 7 Jul 2010 14:04:59 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16350
> 
>            Summary: RTL8103EL interface new tcp connections get stuck on
>                     SYN_SENT state after 10 hours uptime
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.34.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: zic422@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=27038)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=27038)
> ioports, iomem, lspci, ver_linux and kernel config
> 
> After 9-11 hours uptime network interface of RTL8103EL card cannot make new tcp
> connections to internet and correctly close existing ones. ICMP and UDP works
> fine. Besides r8169 driver I tried also the r8101-1.015.00 one from realtek
> site with older kernel and bug were in place.
> 
> Connections inside home network work normally. I tried to reboot router but 
> nor reconnecting ethernet cable nor restarting network daemon nor reloading
> kernel module does not make any help. Bug disappears only after rebooting my
> pc.
> 
> repeatability of bug is 100% on arch, debian and gentoo
> 
> default kernel config
> 
> http://bugs.archlinux.org/task/19162  (this bug)

