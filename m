From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 36562] New: e1000 network driver causes kernel
 oops
Date: Thu, 2 Jun 2011 12:32:04 -0700
Message-ID: <20110602123204.7090c009.akpm@linux-foundation.org>
References: <bug-36562-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bryan.christ@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33546 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754544Ab1FBTcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 15:32:32 -0400
In-Reply-To: <bug-36562-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 2 Jun 2011 19:20:08 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=36562
> 
>            Summary: e1000 network driver causes kernel oops
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.38.6-26.rc1.fc14.x86_64
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: bryan.christ@gmail.com
>         Regression: No
> 
> 
> After running for about 12-48 hours we typically have several servers which
> kernel oops on the e1000
> 
> http://www.mediafire.com/imgbnc.php/e65c4a4b220096cabfa8746195898c1c5520b65cdde108921f027a309c179f6a6g.jpg
> 

It crashed deep down in TCP.  That may not be e1000-related.

I think we still have two drivers: e1000 and e1000e.  You're using
e1000e.

