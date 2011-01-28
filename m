From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 27712] New: atl1e data corruption (via NFS
 over TCP)
Date: Fri, 28 Jan 2011 14:36:35 -0800
Message-ID: <20110128143635.ad6f1b3f.akpm@linux-foundation.org>
References: <bug-27712-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-new@lists.osdl.org,
	bugme-daemon@bugzilla.kernel.org, pmjdebruijn@pcode.nl,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50847 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278Ab1A1Whg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:37:36 -0500
In-Reply-To: <bug-27712-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 28 Jan 2011 09:48:13 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=27712
> 
>            Summary: atl1e data corruption (via NFS over TCP)
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.38-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: pmjdebruijn@pcode.nl
>         Regression: No
> 
> 
> With the following device (very common on ASUS hardware):
> 
>   Atheros AR8121/AR8113/AR8114 PCI-E Ethernet Controller
> 
> With PCI ID: 
> 
>   1969-1026-b0-00-1043-14f5
>   http://pci-ids.ucw.cz/read/PC/1969/1026
> 
> We get data corruption when transferring data via NFS over TCP, while data
> transfered via NFS over UDP seems to be fine.
> 
> We tested this by md5summing large files (100MB+) over NFS.
> 
> Turning off all offload features via ethool does not help either. However the
> RX checksum offload can't be turned off individually, but _seems_ to be turned
> off when the TX checksum offload is turned off.
> 
> As indicated when transferring data via UDP the problem disappears, and the
> md5sums are correct again.
> 
> The above would suggestion something is possibly wrong the RX checksum offload? 
> 
> Is there any way to force the RX checksum offload off?
> 

