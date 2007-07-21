From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8789] New: Error inserting ipt_LOG (mod_path):
 Device or resource busy
Date: Sat, 21 Jul 2007 01:02:07 -0700
Message-ID: <20070721010207.b88e1364.akpm@linux-foundation.org>
References: <bug-8789-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, t.artem@mailcity.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35358 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932449AbXGUIC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 04:02:26 -0400
In-Reply-To: <bug-8789-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 21 Jul 2007 00:44:08 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8789
> 
>            Summary: Error inserting ipt_LOG (mod_path): Device or resource
>                     busy

A 2.6.12 -> 2.6.22 regression.

>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: t.artem@mailcity.com
> 
> 
> Most recent kernel where this bug did not occur: 2.6.21.6
> Distribution: Fedora 7
> Hardware Environment: irrelevant
> Software Environment: Fedora 7 + vanilla kernel 2.6.22
> Problem Description:
> 
> After I upgraded to 2.6.22 kernel, my iptables configuration no longer works
> and I get the above error message. When the error occurs I have these iptables
> modules loaded:
> 
> [root@localhost sysconfig]# lsmod | egrep "x._|ipt" | awk '{print $1}'
> xt_limit
> xt_tcpudp
> xt_pkttype
> ipt_ULOG
> xt_multiport
> iptable_filter
> ip_tables
> x_tables
> 
> [root@localhost sysconfig]# modprobe ipt_LOG
> FATAL: Error inserting ipt_LOG
> (/lib/modules/2.6.22-k8l/kernel/net/ipv4/netfilter/ipt_LOG.ko): Device or
> resource busy
> 
> If I remove all iptables modules then I can successfully modprobe ipt_LOG.
> 
> Steps to reproduce: boot the PC or # service iptables start

