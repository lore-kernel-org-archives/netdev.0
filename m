From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 36122] New: New cache learned PMTU information
 in inetpeer causes ssh to fail when tunneled via an IPSEC VPN
Date: Mon, 6 Jun 2011 13:48:41 -0700
Message-ID: <20110606134841.d7700212.akpm@linux-foundation.org>
References: <bug-36122-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, blueness@gentoo.org,
	kernel@gentoo.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37384 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757302Ab1FFUtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:49:39 -0400
In-Reply-To: <bug-36122-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 28 May 2011 21:50:32 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=36122
> 
>                URL: http://bugs.gentoo.org/show_bug.cgi?id=369025
>            Summary: New cache learned PMTU information in inetpeer causes
>                     ssh to fail when tunneled via an IPSEC VPN
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.39
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: blueness@gentoo.org
>                 CC: kernel@gentoo.org
>         Regression: No
> 
> 
> When trying to ssh from a box running 2.6.39 on one private subnet to another
> box on another private subnet via an IPSEC vpn, ssh freezes and times out at:
> 
>    debug1: expecting SSH2_MSG_KEX_DH_GEX_GROUP
> 
> This was traced down to commit 2c8cec5c10bced2408082a6656170e74ac17231c.
> 
> This type of error is known to occur when there is fragmentation due to
> mismatched mtu's which the commit addresses.
> 
> Notice the problem does not occur when ssh-ing directly, ie not via an IPSEC
> tunnel.  I have not tested if other tunnels are affected.
> 
> Please see the downstream bug for more details.
> 

