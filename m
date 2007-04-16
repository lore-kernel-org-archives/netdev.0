From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8338] New: NAT of TCP connections broken
Date: Mon, 16 Apr 2007 13:48:28 -0700
Message-ID: <20070416134828.5885b451.akpm@linux-foundation.org>
References: <200704162035.l3GKZlTI002693@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, ernisv@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49934 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754255AbXDPUsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 16:48:35 -0400
In-Reply-To: <200704162035.l3GKZlTI002693@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, 16 Apr 2007 13:35:47 -0700 bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=8338
> 
>            Summary: NAT of TCP connections broken
>     Kernel Version: 2.6.20.7
>             Status: NEW
>           Severity: high
>              Owner: networking_netfilter-iptables@kernel-bugs.osdl.org
>          Submitter: ernisv@gmail.com
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.18
> Distribution: Debian
> Hardware Environment: amd64 4200x2
> Software Environment:
> Problem Description:
> I'm using my debian box for sharing internet connection. After update to 
> debian's 2.6.20 kernel (and adjusting new kernel configuration for NAT) NAT of 
> TCP connections stoped working, while ICMP and UDP is working (ping, traceroute 
> and DNS). When trying to open web page on a PC from my LAN (tried with linux 
> and winxp), it sends the request but is unable to receive correct response from 
> any site. On the router PC www works ok. 
> 
> I tried both new "Independent connection tracking" as well as "Dependent 
> (obsolete) connection tracking" options with no luck.
> 
> tcp_window_scaling setting seems to have no effect.
> 
