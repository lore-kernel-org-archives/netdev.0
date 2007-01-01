From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7757] New: ip_conntrack:table full, dropping
 connection after kernel update
Date: Sun, 31 Dec 2006 20:46:34 -0800
Message-ID: <20061231204634.f43136e8.akpm@osdl.org>
References: <200701010303.l0133YLp007451@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, joelol75@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:44666 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932904AbXAAEqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Dec 2006 23:46:44 -0500
To: netdev@vger.kernel.org
In-Reply-To: <200701010303.l0133YLp007451@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 31 Dec 2006 19:03:34 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7757
> 
>            Summary: ip_conntrack:table full, dropping connection after
>                     kernel update
>     Kernel Version: 2.6.19.1
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: joelol75@verizon.net
> 
> 
> Most recent kernel where this bug did *NOT* occur:2.6.10
> Distribution:Kubuntu
> Hardware Environment:AMD64X2, Geforce6100 North, NForce 430 South, forcedeth driver
> Software Environment:
> Problem Description:dmesg shows above/dead network.  netstat shows piles of
> FIN_WAIT1 connections, using same /proc/sys/net/ipv4 settings
> 
> Steps to reproduce: Update Edgy 2.6.17-10 kernel with vanilla &.1 patch. Turned
> on DMA engine, and nv_sata with k7 (32 bit kernel) optimizations (only changes).
>  Used GTK-gnutella or any p2p that really wrings out the ip stack.  A few hours
> later bandwidth slows to a crawl and only currently open connections are alive.   
> 
> Bring down the network and bringing it back up to clear the tables doesn't
> remove the fin_wait1's.  Any workarounds or maybe a new setting that I
> overlooked that the kernel needs would be greatly appc'd.
> 
> Cheers.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
