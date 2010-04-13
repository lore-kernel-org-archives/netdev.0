From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15720] New: IPv6's ipv4-compatibility
 addresses don't bind
Date: Mon, 12 Apr 2010 21:22:41 -0400
Message-ID: <20100412212241.d8bf4185.akpm@linux-foundation.org>
References: <bug-15720-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, charles@kde.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54932 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750727Ab0DMEZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 00:25:41 -0400
In-Reply-To: <bug-15720-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 7 Apr 2010 23:17:32 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15720
> 
>            Summary: IPv6's ipv4-compatibility addresses don't bind

A 2.6.9 -> 2.6.32 regression ;)

>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32-2-686-bigmem
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: charles@kde.org
>         Regression: Yes
> 
> 
> When attempting to bind to an address using ipv4-compatibility, for example,
> "::ffff:127.0.0.1", Linux refuses to bind to that address when
> /proc/sys/net/ipv6/bindv6only is set.
> 
> Yes, you could say "but you specifically told ipv6 to not bind to ipv4
> addresses!" However, ::ffff:127.0.0.1 is *clearly* an ipv4 address, it's not an
> alternate representation of an ipv6 address, it's an ipv4 address and only
> ipv4.
> 
> This seems to not have been the case as of linux 2.6.9, although I'm not sure
> at what version this changed.
> 
> It seems to me that the intent of "bindv6only" was to not bind to the ipv4
> address when you bind to all addresses (specifically ipv6 address "::"). So
> when you bind to ::, an ipv4 client connects to you, and it appears to be
> connecting from ::ffff:192.168.5.5. I don't think its intent was to effectively
> disable binding to ::ffff:x.x.x.x addresses - just breaking that feature makes
> no sense.
> 
> The Linux 2.6.9 approach seems to match MacOS's (and I'm pretty sure Solaris's,
> too).


