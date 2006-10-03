From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7254] New: leaving IP multicast group with
 incorrect imr_address unexpectedly succeeded
Date: Tue, 3 Oct 2006 10:07:50 -0700
Message-ID: <20061003100750.902d4837.akpm@osdl.org>
References: <200610031440.k93Ee4pP018478@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, Konstantin.Petrov@oktetlabs.ru,
	Alexandra.Kossovsky@oktetlabs.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43756 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030331AbWJCRIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 13:08:07 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200610031440.k93Ee4pP018478@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006 07:40:04 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7254
> 
>            Summary: leaving IP multicast group with incorrect imr_address
>                     unexpectedly succeeded
>     Kernel Version: 2.6.18
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: Konstantin.Petrov@oktetlabs.ru
>                 CC: Alexandra.Kossovsky@oktetlabs.ru
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:
> Hardware Environment: P4 PC
> Software Environment:
> Problem Description:
> 
> When trying to leave IP multicast group with
> incorrect imr_address we expect function
> setsockopt(s, SOL_IP, IP_DROP_MEMBERSHIP, ip_mreq)
> to fail with ERRNO EADDRNOTAVAIL, but it succeeds.
> 
> Steps to reproduce:
> 1) Join socket to IP multicast group
> 2) Using incorrerct imr_address try to leave 
>    IP multicast group
> 
> Note:
> Probably function ip_mc_leave_group(...) in the
> file /net/ipv4/igmp.c "forgets" to check imr_address when
> imr_ifindex is OK.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
