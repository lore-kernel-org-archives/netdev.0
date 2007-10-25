From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9224] New: Settings to
 /proc/sys/net/ipv[46]/conf/all are not propagated
Date: Thu, 25 Oct 2007 09:16:52 -0700
Message-ID: <20071025091652.0d7002c1.akpm@linux-foundation.org>
References: <bug-9224-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, svdb+linux-kernel-bugs@stack.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38196 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750732AbXJYQRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 12:17:32 -0400
In-Reply-To: <bug-9224-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Oct 2007 04:44:06 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9224
> 
>            Summary: Settings to /proc/sys/net/ipv[46]/conf/all are not
>                     propagated
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: svdb+linux-kernel-bugs@stack.nl
> 
> 
> Most recent kernel where this bug did not occur: 2.6.22 (not sure)
> Distribution: custom
> Hardware Environment: See attached files
> Software Environment: See attached files.
> Problem Description: Changing a setting in /proc/sys/net/ipv[46]/conf/all does
> not propagate the setting to the individual network interfaces, for most
> settings.
> 
> Steps to reproduce:
> # cat /proc/sys/net/ipv6/conf/{all,default,lo,eth0}/autoconf
> 1
> 1
> 1
> 1
> # echo 0 > /proc/sys/net/ipv6/conf/all/autoconf
> # echo 0 > /proc/sys/net/ipv6/conf/default/autoconf
> # cat /proc/sys/net/ipv6/conf/{all,default,lo,eth0}/autoconf
> 0
> 0
> 1
> 1
> 
> The problem occurs for other settings than "autoconf", but not for all.
> "forwarding" is one which does work.
> 
> Changing settings for individual interfaces still works.
> 
> The problem is not specific to ipv6.
> 

Apparently a regression.
