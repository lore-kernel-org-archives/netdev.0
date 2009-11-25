From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14685] New: 2.6.30 -> 2.6.31: very high number
 of RX dropped in bnx2
Date: Wed, 25 Nov 2009 12:47:13 -0800
Message-ID: <20091125124713.f7ac10e4.akpm@linux-foundation.org>
References: <bug-14685-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, olel@ans.pl
To: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36785 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759108AbZKYUr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 15:47:26 -0500
In-Reply-To: <bug-14685-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 25 Nov 2009 00:16:00 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14685
> 
>            Summary: 2.6.30 -> 2.6.31: very high number of RX dropped in
>                     bnx2
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.31.6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: olel@ans.pl
>         Regression: Yes
> 
> 
> After upgradig my kernel from 2.6.30 to 2.6.31 I'm observing very high number
> of dropped packets on BCM5708(Dell PowerEdge 1950)/BCM5716(Dell PowerEdge R410)
> NICs.
> 
> # uptime ; ifconfig eth0|grep "RX p"; ethtool -S eth0|grep disc
>  01:07:31 up 6 min,  1 user,  load average: 0.00, 0.07, 0.04
>           RX packets:2234 errors:0 dropped:527 overruns:0 frame:0
>      rx_discards: 0
>      rx_fw_discards: 527
> 
> Everything seems to work just fine so I suspect that the driver/firmware is
> counting something wrong.
> 

