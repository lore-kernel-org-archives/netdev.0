From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15507] New: kernel misses 3rd part of tcp
 handshake (ACK), stays in SYN_RECV state
Date: Thu, 18 Mar 2010 16:01:03 -0700
Message-ID: <20100318160103.cc28c367.akpm@linux-foundation.org>
References: <bug-15507-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, roysjosh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58070 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752577Ab0CRXBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 19:01:42 -0400
In-Reply-To: <bug-15507-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 10 Mar 2010 14:50:51 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15507
> 
>            Summary: kernel misses 3rd part of tcp handshake (ACK), stays
>                     in SYN_RECV state
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.9-67.fc12
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: roysjosh@gmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=25450)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=25450)
> tcpdump from virtual guest over ::1 showing dup synacks
> 
> Setup:
> 64-bit dual-core, latest F12.  (I've experienced this on .31 and .32 kernels.)
> 
> I have also experienced this on 2 other machines, all 64-bit.  One was a
> single-core virtual guest.
> 
> 1. Install httpd.
> 2. Start it.  Don't bother configuring anything unless you need to.
> 3. tcpdump .....
> 4. connect from localhost or (possibly) a nearby host.  I'm not sure if this is
> timing related yet.
> 5. note duplicate SYN-ACKs sent out at the exponential backoff.  Some setups
> exhibit this more/worse than others, and will actually time out the connection.
>  (Others will only send one or two duplicate SYN-ACKs, and then enter the
> ESTABLISHED state.)  However, if any data is sent the kernel enters
> ESTABLISHED.
> 
> Note that this isn't ipv4 specific.  I have seen it under ipv4 and ipv6 (via
> loopback).
> 

