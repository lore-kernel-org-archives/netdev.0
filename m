From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12109] New: Multicast packets with TTL 0 sent
 out if not local listener
Date: Thu, 27 Nov 2008 09:34:12 -0800
Message-ID: <20081127093412.9536e5cc.akpm@linux-foundation.org>
References: <bug-12109-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, jani@ubuntu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52361 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751720AbYK0ReS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 12:34:18 -0500
In-Reply-To: <bug-12109-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 27 Nov 2008 02:32:27 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12109
> 
>            Summary: Multicast packets with TTL 0 sent out if not local
>                     listener
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: jani@ubuntu.com
> 
> 
> According to what I have read, setting the IP_MULTICAST_TTL option to 0 on a
> multicast sending socket should prevent it sending to the network, and be
> destined only for listeners on the local computer.
> 
> This only seems to work if there is a local listener on that particular group.
> If such a listener app is stopped other computers on the LAN get the messages,
> and tcpdump -v shows they have  TTL 0
> 
> I am not sure if this is intended behaviour but it is unexpected.
> 
> 

