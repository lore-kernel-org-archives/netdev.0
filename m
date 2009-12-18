From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP
 packets
Date: Fri, 18 Dec 2009 15:32:09 -0800
Message-ID: <20091218153209.45042a58.akpm@linux-foundation.org>
References: <bug-14837-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, benoit.papillault@free.fr,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40668 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750879AbZLRXdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 18:33:06 -0500
In-Reply-To: <bug-14837-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 18 Dec 2009 23:10:01 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14837
> 
>            Summary: gretap does not fragment IP packets
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: benoit.papillault@free.fr
>         Regression: No
> 
> 
> When gretap is used to encapsulate Ethernet packets into IP packets, the
> encapsulated IP packets are larger than the original Ethernet packet, as
> expected.
> 
> Let's say you create a gre0 interface with a 1500 bytes MTU (since this
> interface will latter be inserted in a bridge interface, its MTU must be 1500).
> And Let's say the GRE encapsulated packet (now larger than 1500 bytes) is going
> to be routed over an IP interface with a 1500 bytes MTU.
> 
> The expected behavior would be that the encapsulated packet be fragmented. The
> observed behavior is that any encapsulated packets over 1500 bytes are simply
> dropped and an ICMP "fragmentation needed" message is sent to ... who knows.
> 
> My feeling is that DF bit is not playing nice here.
> 

