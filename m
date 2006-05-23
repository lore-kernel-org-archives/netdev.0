From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6610] New: dummy interface broadcast
 destination hardware address is not ff:ff:ff:ff:ff:ff
Date: Tue, 23 May 2006 16:31:42 -0700
Message-ID: <20060523163142.4149e06f.akpm@osdl.org>
References: <200605232316.k4NNGRBp001431@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4587 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932484AbWEWXcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 19:32:10 -0400
To: bugme-daemon@bugzilla.kernel.org
In-Reply-To: <200605232316.k4NNGRBp001431@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6610
> 
>            Summary: dummy interface broadcast destination hardware address
>                     is not ff:ff:ff:ff:ff:ff
>     Kernel Version: 2.6.16
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: byyilxoz@no-spam.hu
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Steps to reproduce:
> 
> ifconfig
> dummy0    Link encap:Ethernet  HWaddr C2:54:E2:F3:38:08
>           inet addr:192.168.100.1  Bcast:192.168.100.255  Mask:255.255.255.0
> 
> tcpdump -XX -i dummy0 icmp
> ping -b -c 1 192.168.100.255
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
