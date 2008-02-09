From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9923] New: Unable conect to internet over ISDN
 AVM USB BlueFritz
Date: Sat, 9 Feb 2008 10:13:47 -0800
Message-ID: <20080209101347.04da24dc.akpm@linux-foundation.org>
References: <bug-9923-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, vasko@arcor.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51559 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752668AbYBISQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 13:16:05 -0500
In-Reply-To: <bug-9923-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 Feb 2008 03:36:26 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9923
> 
>            Summary: Unable conect to internet over ISDN AVM USB BlueFritz
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: vasko@arcor.de
> 
> 
> Latest working kernel version:2.6.22
> Earliest failing kernel version:2.24

A regression.

> Distribution:opensuse 10.3
> Hardware Environment:AVM BlueFritz USB ISDN
> Software Environment:
> Problem Description:
> ifup ippp0
>     ippp0
> SIOCSIFFLAGS: Invalid argument
> Cannot enable interface ippp0
> 
> Steps to reproduce:
> Feb  9 11:20:54 linux-zhr0 klogd: ippp0: dialing 1 019193383... 
> Feb  9 11:20:56 linux-zhr0 klogd: isdn_net: ippp0 connected
> Feb  9 11:20:56 linux-zhr0 klogd: capidrv-1: chan 0 up with ncci 0x10101
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: Local number: 906138, Remote number:
> 019193383, Type: outgoing
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: PHASE_WAIT -> PHASE_ESTABLISHED,
> ifunit: 0, linkunit: 0, fd: 7
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: ioctl(SIOCSIFMTU): Invalid argument, 6
> ippp0 1524.
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: MPPP negotiation, He: Yes We: Yes
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: CCP enabled! Trying CCP.
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: CCP: got ccp-unit 0 for link 0
> (Compression Control Protocol)
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: ccp_resetci!
> Feb  9 11:20:56 linux-zhr0 ipppd[5624]: ccp_resetci!
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from peer slot(0)
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-rcv[0]: 01 01 00 09 11 05 00 01 04 
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from daemon:
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-xmit[0]: ff 03 80 fd 01 01 00 04 
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from daemon:
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-xmit[0]: ff 03 80 fd 04 01 00 09 11
> 05 00 01 04 
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from peer slot(0)
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-rcv[0]: 04 01 00 04 
> Feb  9 11:20:58 linux-zhr0 ipppd[5624]: ccp_resetci!
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from peer slot(0)
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-rcv[0]: 01 02 00 0a 11 06 00 01 01
> 03 
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from daemon:
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-xmit[0]: ff 03 80 fd 01 02 00 04 
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from daemon:
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-xmit[0]: ff 03 80 fd 04 02 00 0a 11
> 06 00 01 01 03 
> Feb  9 11:20:58 linux-zhr0 klogd: Received CCP frame from peer slot(0)
> Feb  9 11:20:58 linux-zhr0 klogd: [0/0].ccp-rcv[0]: 04 02 00 04 
> Feb  9 11:20:59 linux-zhr0 ipppd[5624]: local  IP address 149.225.68.4
> Feb  9 11:20:59 linux-zhr0 ipppd[5624]: remote IP address 139.4.250.4
> Feb  9 11:20:59 linux-zhr0 ipppd[5624]: Ifup: ioctl(SIOCSIFFLAGS): Invalid
> argument
> Feb  9 11:20:59 linux-zhr0 ip-down: SIOCSIFFLAGS: Invalid argument
> 

