From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11655] New: /proc/sys/net/ipv6/conf/all/*
 controls don't work
Date: Thu, 2 Oct 2008 23:18:26 -0700
Message-ID: <20081002231826.869a1a9e.akpm@linux-foundation.org>
References: <bug-11655-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, adwol@zonk.pl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54991 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752802AbYJCGS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 02:18:29 -0400
In-Reply-To: <bug-11655-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 26 Sep 2008 19:36:55 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11655
> 
>            Summary: /proc/sys/net/ipv6/conf/all/* controls don't work
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: adwol@zonk.pl
> 
> 
> Latest working kernel version: NONE
> Earliest failing kernel version: UNKNOWN
> Distribution: Various, mostly Slackware and PLD
> Hardware Environment: ANY
> Software Environment: ANY
> Problem Description: `echo 0 > /proc/sys/net/ipv6/conf/all/autoconf' doesn't
> disable interfaces autoconfiguration
> 
> Steps to reproduce:
> Changing values of /proc/sys/net/ipv6/conf/all/autoconf,
> /proc/sys/net/ipv6/conf/all/accept_ra and probably other
> /proc/sys/net/ipv6/conf/all/* controls don't cause anything.
> After `echo 0 > /proc/sys/net/ipv6/conf/all/autoconf' system still accepts
> router advertisement packets from gateway on every interface and set
> autoconfigured addresses.
> 
> Situation is rather deeper because autoconf is only an example and problem
> afflicts /proc/sys/net/ipv6/conf/all/* controls generally.
> 

