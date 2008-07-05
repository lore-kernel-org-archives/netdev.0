From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11036] New: atl1 tx busy and hw csum wrong
Date: Sat, 5 Jul 2008 12:23:48 -0700
Message-ID: <20080705122348.e9b55b57.akpm@linux-foundation.org>
References: <bug-11036-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Jay Cliburn <jacliburn@bellsouth.net>, scurippio@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50428 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751344AbYGETXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 15:23:52 -0400
In-Reply-To: <bug-11036-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat,  5 Jul 2008 03:54:15 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11036
> 
>            Summary: atl1 tx busy and hw csum wrong
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24-1-amd64
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: scurippio@gmail.com
> 
> 
> Latest working kernel version:
> Earliest failing kernel version:
> Distribution: Debian amd64 lenny
> Hardware Environment: Ethernet controller: Attansic Technology Corp. L1 Gigabit
> Ethernet Adapter (rev b0)
> Software Environment: atl1 module
> Problem Description:
> dmesg get flooded on irregular intervals by
> atl1 0000:01:00.0: tx busy
> and
> atl1 0000:01:00.0: hw csum wrong, pkt_flag:1600, err_flag:80
> 
> There aren't any visibile problems with it.
> 
> eth0      Link encap:Ethernet  HWaddr 00:1e:8c:a9:bf:11  
>           inet addr:192.168.66.2  Bcast:192.168.66.255  Mask:255.255.255.0
>           inet6 addr: fe80::21e:8cff:fea9:bf11/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:80176035 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:75185297 errors:0 dropped:0 overruns:0 carrier:17
>           collisions:0 txqueuelen:1000 
>           RX bytes:76786214500 (71.5 GiB)  TX bytes:57132572737 (53.2 GiB)
> 
> 
> Steps to reproduce: don't know exactly, probably under high network load.
> 

