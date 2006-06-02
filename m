From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6638] New: tg3 output freezes on compaq nc6000
Date: Fri, 2 Jun 2006 11:22:48 -0700
Message-ID: <20060602112248.821c9063.akpm@osdl.org>
References: <200606021240.k52CepX2017904@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Klaus.Reichl@alcatel.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7138 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751435AbWFBSXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 14:23:01 -0400
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
In-Reply-To: <200606021240.k52CepX2017904@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Jun 2006 05:40:51 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=6638
> 
>            Summary: tg3 output freezes on compaq nc6000
>     Kernel Version: 2.6.16.19
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: Klaus.Reichl@alcatel.at
> 
> 
> Most recent kernel where this bug did not occur: none
> Distribution: Debian Sarge with latest kernel
> Hardware Environment: compaq nc6000
> Software Environment: 
> Problem Description: 
> The output engine of the tg3 driver freezes when generating high load.
> 
> `ifconfig' shows incomming packets, however, outgoing counter is not incremented
> any more.
> 
> Resetting the device (ifdown eth0, ifup eth0) heals the problem.
> 
> Steps to reproduce:
> Heavily copy files to NFS disk.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
