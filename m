From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10063] New: Network problems with 2.6.23+
Date: Sun, 24 Feb 2008 23:09:22 -0800
Message-ID: <20080224230922.50d44ba0.akpm@linux-foundation.org>
References: <bug-10063-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, zibbe@cisko.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:36352 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbYBYHJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 02:09:55 -0500
In-Reply-To: <bug-10063-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(plese respond via emailed reply-to-all, not via the bugzilla web interface)

On Thu, 21 Feb 2008 18:04:45 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10063

There's more info (including a tcpdump) in bugzilla.

>            Summary: Network problems with 2.6.23+
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: zibbe@cisko.org
> 
> 
> Latest working kernel version: 2.6.23
> Earliest failing kernel version: 2.6.24
> Distribution: Gentoo
> Hardware Environment: 
> 
> model name      : Dual Core AMD Opteron(tm) Processor 170
> stepping        : 2
> cpu MHz         : 2009.144
> 
> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
> Gigabit Ethernet Controller (rev 15) sky2
> 
> Working on 2.6.24 (as far as I can see) in :
> 
> model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
> stepping        : 9
> cpu MHz         : 2793.222
> 01:01.0 Ethernet controller: Intel Corporation 82547GI Gigabit Ethernet
> Controller
> 
> Software Environment: TCP-transfers (FTP,HTTP)
> Problem Description:
> 
> First I want to apologize that I'm not able to do alot of troubleshooting on
> this issue cause I don't know where to start exactly.
> 
> The problem is that I have, after upgrading to 2.6.24 from 2.6.23, experienced
> alot of "weird" network problems. For example, FTP-transfers to certain hosts
> on the Internet stalls after a while. I have one dst-host where this problem
> appears frequently. On another dst-host it doesn't happen as often. Sometimes
> the transfers doesn't even start. 
> 
> First we did alot of faultracing on the transmission but after downgrading the
> kernel it was apparent that the transmission wasn't the problem. 
> 
> I did not think about filing this report until i saw,
> http://kerneltrap.org/node/15550. So I guess I'm not alone.
> 
> I must also add that to some dst-hosts there is no problem at all. So I would
> guess that there might be something with the mtu,wscale or something between
> hosts. 
> 
> All the other dst-hosts I've tried is running 2.6.23
> 
> I will try to test alot of kernel-version to try to ease the troubleshooting. 
> 
> 
> Steps to reproduce:
> 
> Start an FTP-transfer from the box mention above.

I guess it might help if you can tell us the IP address of some of the
problematic servers.

