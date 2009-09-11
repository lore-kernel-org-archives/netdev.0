From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14147] New: System unresponsive if I unplug
 network cable while ethtool -p is running
Date: Fri, 11 Sep 2009 12:55:46 -0700
Message-ID: <20090911125546.52185035.akpm@linux-foundation.org>
References: <bug-14147-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, david.graham@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45885 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756105AbZIKTzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 15:55:45 -0400
In-Reply-To: <bug-14147-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 9 Sep 2009 00:06:10 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14147
> 
>            Summary: System unresponsive if I unplug network cable while
>                     ethtool -p is running
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: david.graham@intel.com
>         Regression: No
> 
> 
> When a user runs the "ethtool -p ethX" to identify the physical interface by
> flashing the appropriate interface LED, and then removes the cable at that
> interface, the keyboard locks up. This is naturally annoying to customers with
> multi-port systems, who wish to use ethtool -p so that they can
> disconnect/connect interface cables to appropriate ports. 
> 
> I am told that this is because "the RTNL lock is held by ethtool, and the link
> [down] message needs the RTNL", which would, I think, make this a kernel issue. 
> 
> This has been known about within INTEL for over 3 years, but only recently come
> to my attention. I have verified it on a 2.6.30 system using a default kernel
> configuration and the e1000e driver.
> 

hah.  cute.
