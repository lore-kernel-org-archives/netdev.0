From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9349] New: RTNLGRP_ND_USEROPT does not report
 ifindex
Date: Sun, 11 Nov 2007 11:59:03 -0800
Message-ID: <20071111115903.90f0fdc0.akpm@linux-foundation.org>
References: <bug-9349-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, rdenis@simphalempin.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50063 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756145AbXKKT7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 14:59:42 -0500
In-Reply-To: <bug-9349-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 11 Nov 2007 10:52:41 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9349
> 
>            Summary: RTNLGRP_ND_USEROPT does not report ifindex
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: rdenis@simphalempin.com
> 
> 
> Most recent kernel where this bug did not occur: none
> Distribution: N/A
> Hardware Environment: any
> Software Environment: any
> Problem Description:
> The RTNLGRP_ND_USEROPT NetLink message introduced in 2.6.24 does not seem to
> include any information as to which netif the user options come from:
> 
> struct nduseroptmsg
> {
>         unsigned char   nduseropt_family;
>         unsigned char   nduseropt_pad1;
>         unsigned short  nduseropt_opts_len; /* Total length of options */
>         __u8            nduseropt_icmp_type;
>         __u8            nduseropt_icmp_code;
>         unsigned short  nduseropt_pad2;
>         /* Followed by one or more ND options */
> };
> 
> Considering this is meant to carry data that is heavily link-layer involved,
> this seems like a feature bug. Could an ifindex field be added there??
> 
