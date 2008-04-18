From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering
 down PHY"
Date: Thu, 17 Apr 2008 17:12:15 -0700
Message-ID: <20080417171215.f7fbba3b.akpm@linux-foundation.org>
References: <bug-10473-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, naoliv@gmail.com
To: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33280 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752226AbYDRANI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 20:13:08 -0400
In-Reply-To: <bug-10473-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 17 Apr 2008 17:08:27 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10473
> 
>            Summary: Infinite loop "b44: eth0: powering down PHY"
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: naoliv@gmail.com
> 
> 
> Latest working kernel version: 2.6.24.4 (from Debian)
> Earliest failing kernel version: 2.6.25 (vanilla)
> Distribution: Debian
> Problem Description:
> 
> While booting the new 2.6.25 Kernel, it enters an infinite looping displaying
> "b44: eth0: powering down PHY".
> The system isn't freezed as magick SysRq keys works, but it just stay
> displaying those messages. I am unable to dump any information using SysRq,
> however (as the b44(...) messages are too fast).
> 
> I will attach lspci output and my .config
> 

Apparently a regression.
