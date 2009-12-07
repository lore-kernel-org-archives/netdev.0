From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14737] New: e1000e driver experiences large
 packet losses
Date: Mon, 7 Dec 2009 13:19:00 -0800
Message-ID: <20091207131900.19c776ed.akpm@linux-foundation.org>
References: <bug-14737-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	xenoterracide@gmail.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46797 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964975AbZLGVTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 16:19:31 -0500
In-Reply-To: <bug-14737-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 5 Dec 2009 07:02:49 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14737
> 
>            Summary: e1000e driver experiences large packet losses
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32--
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: xenoterracide@gmail.com
>         Regression: No
> 
> 
> possibly related to this bug #13835 same symptoms and I upped a lot of info for
> this bug on there.
> 
> Also Read this thread http://marc.info/?t=125699907100001&r=1&w=2
> 
> I have thus far been able to find similar symptoms all the way back to 2.6.29.6
> I've not yet done testing farther. problem is intermittent. It does not appear
> to affect another nic on the system (however testing of that hasn't been
> extensive,and a different driver). if I do not reboot the computer and the bug
> hasn't manifested, it will not manifest (perhaps unless I reload modules or
> restart interfaces (not tested).
> 

