From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13398] New: sky2 occasionally fails to
 recognize device on cold boot
Date: Fri, 29 May 2009 14:09:20 -0700
Message-ID: <20090529140920.c5d964b4.akpm@linux-foundation.org>
References: <bug-13398-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	thomas.burdick@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34607 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752430AbZE2VJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 17:09:51 -0400
In-Reply-To: <bug-13398-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 28 May 2009 16:26:36 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13398
> 
>            Summary: sky2 occasionally fails to recognize device on cold
>                     boot
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: thomas.burdick@gmail.com
>         Regression: No
> 
> 
> occasionally the sky2 module will report in dmesg
> 
> sky2 0000:02:00.0: unsupported chip type 0xff
> 
> on a cold boot, unloading and reloading the module gives the same error.
> 
> the network adapter is unusable. A warm reboot and the network adapter is
> usable and the sky2 module reports success.
> 
> This is in a hp 1035nr netbook with, according to lspci, 
> Marvell 88E8040 PCE-E Fast Ethernet Controller
> 

