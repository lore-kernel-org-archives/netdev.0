From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9778] New: unregister_netdevice: waiting for
 [device] to become free
Date: Sat, 19 Jan 2008 16:58:02 -0800
Message-ID: <20080119165802.2846a28e.akpm@linux-foundation.org>
References: <bug-9778-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, nigel@suspend2.net,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44363 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751674AbYATA5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 19:57:54 -0500
In-Reply-To: <bug-9778-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Jan 2008 12:20:28 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9778
> 
>            Summary: unregister_netdevice: waiting for [device] to become
>                     free
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: nigel@suspend2.net
> 
> 
> Latest working kernel version: 2.6.24-rc7
> Earliest failing kernel version: 2.6.24-rc8
> Distribution: Ubuntu Gutsy
> Hardware Environment: AMD64, Atheros 5212 chipset
> Software Environment: Fairly recent madwifi svn.
> Problem Description: Patch "[PATCH][NEIGH] Fix race between neigh_parms_release
> and neightbl_fill_parms" (9cd40029423701c376391da59d2c6469672b4bed) causes the
> error described in the subject line to occur when seeking to unload a device.
> Also seen by some of my TuxOnIce users with e1000 and ppp42.
> 
> Steps to reproduce: Run a kernel with the above patch, bring up a (nonloopback)
> interface, seek to take it down.
> 

ouch.
