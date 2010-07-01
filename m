From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16293] New: 82545GM in newest kernel not
 working.
Date: Thu, 1 Jul 2010 14:00:41 -0700
Message-ID: <20100701140041.df2d147c.akpm@linux-foundation.org>
References: <bug-16293-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lukas.valach@zoznam.sk
To: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40097 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932868Ab0GAVBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 17:01:51 -0400
In-Reply-To: <bug-16293-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 25 Jun 2010 17:48:43 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16293
> 
>            Summary: 82545GM in newest kernel not working.
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32.15
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: lukas.valach@zoznam.sk
>         Regression: No
> 
> 
> lspci:
> 
> 01:01.0 Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet
> Controller (rev 04)
> 01:02.0 Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet
> Controller (rev 04)
> 02:01.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
> Controller (rev 03)
> 02:01.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
> Controller (rev 03)
> 
> All interface are correctly configured. In kernel <2.6.26 get all OK, in newest
> kernels network interfaces are not working. Problem is in driver e1000. Tested
> on 2.6.31,2.6.32,2.6.34 and 2.6.35rc.

A somewhat old e1000 regression?
