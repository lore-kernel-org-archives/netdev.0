From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8382] New: 2.6.20 cannot route packets outside
 tunnel
Date: Fri, 27 Apr 2007 16:05:54 -0700
Message-ID: <20070427160554.8419450c.akpm@linux-foundation.org>
References: <200704272301.l3RN14As026026@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, frlinux@frlinux.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34661 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757863AbXD0XGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 19:06:09 -0400
In-Reply-To: <200704272301.l3RN14As026026@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

,On Fri, 27 Apr 2007 16:01:04 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8382
> 
>            Summary: 2.6.20 cannot route packets outside tunnel
>     Kernel Version: 2.6.20.9
>             Status: NEW
>           Severity: high
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: frlinux@frlinux.net
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.19.7
> Distribution: Debian Etch 4.0
> Hardware Environment: i386 VIA Samuel 2 700mhz
> Software Environment: Debian Etch 
> Problem Description:
> 
> I am using an IPv6 tunnel broker (SixXs) which is using aiccu (dynamic IPv4
> address using heartbeat to get in sync with IPv6 tunnel to SixXS). When using
> 2.6.20.x it doesn't route packets outside the tunnel anymore. This means that
> from my gateway, i can ping my local interface and my remote one but not a
> single other IPv6 address.
> 
> When trying to traceroute or send IPv6 packets from any other machine on my
> network to an outside IPv6 address, i keep getting a network unreachable message.
> 
> This was tested against 2.6.20.{5,7,8,9} and also 2.6.19.6/7. It works perfectly
> on any 2.6.19.x kernel or previous but fails under 2.6.20.x
> 
> I made a diff in the IPv6 stack between 19 and 20 but my programming skills are
> clearly lacking :(
> 
> Steps to reproduce:
> 
> Compile with IPv6 settings that I am including with this bug report, 2.6.19
> works, 2.6.20 doesn't.

