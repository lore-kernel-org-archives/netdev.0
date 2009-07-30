From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13862] New: PROBLEM: SiS 191 mtu bug
Date: Thu, 30 Jul 2009 13:56:50 -0700
Message-ID: <20090730135650.0b6aa972.akpm@linux-foundation.org>
References: <bug-13862-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, wipat.s@psu.ac.th,
	Riccardo Ghetta <birrachiara@tin.it>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47944 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751629AbZG3U5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:57:30 -0400
In-Reply-To: <bug-13862-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 29 Jul 2009 08:02:32 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13862
> 
>            Summary: PROBLEM: SiS 191 mtu bug
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.28-14, 2.6.29-06
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: wipat.s@psu.ac.th
>         Regression: Yes
> 
> 
> Problem Description:
> incorrect MTU size. Command 'ifconfig eth0' show MTU:1500,
> but network failed with packet large more than 1024.
> Modifying the mtu of the ethernet interface to 1024 
> with command 'ifconfig eth0 mtu 1024' make it to work.
> 
> Keyword: networking
> Kernel version Linux ubuntu 2.6.28-14-server, Linux 2.6.29.06-std122
> 

drivers/net/sis190.c

It's a regression, but we're not sure since when.
