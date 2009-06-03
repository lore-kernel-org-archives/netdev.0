From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13443] New: Scope 1 in multicast addresses in
 IPV6 should be node local
Date: Wed, 3 Jun 2009 14:40:31 -0700
Message-ID: <20090603144031.2945f24d.akpm@linux-foundation.org>
References: <bug-13443-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, aviad.yehezkel5@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58748 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753097AbZFCVkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:40:31 -0400
In-Reply-To: <bug-13443-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 3 Jun 2009 16:06:29 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13443
> 
>            Summary: Scope 1 in multicast addresses in IPV6 should be node
>                     local
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: aviad.yehezkel5@gmail.com
>         Regression: No
> 
> 
> I think scope 1 in multicast addresses in IPV6 should be node local (according
> to all the documentation + rfc I found on the web) and therefore pkt's with
> such destination address should not go on the wire.
> When I try to send a udp pkt with sock_dgram to such ipv6 address with scope 1
> I see the pkt is going on the wire and I can catch it on the other side by
> joining this multicast address.

