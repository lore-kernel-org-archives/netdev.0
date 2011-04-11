From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 33042] New: Marvell 88E1145 phy configured
 incorrectly in fiber mode
Date: Mon, 11 Apr 2011 14:02:39 -0700
Message-ID: <20110411140239.646ace73.akpm@linux-foundation.org>
References: <bug-33042-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, Alex Dubov <oakad@yahoo.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44073 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239Ab1DKVDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 17:03:30 -0400
In-Reply-To: <bug-33042-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 11 Apr 2011 09:28:18 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=33042
> 
>            Summary: Marvell 88E1145 phy configured incorrectly in fiber
>                     mode
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: Linux-2.6.39-rc1-00191
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: oakad@yahoo.com
>         Regression: No
> 
> 
> On my board, Marvell 88E1145 phy is attached to Freescale gianfar controller.
> Backplane connection is detected by u-boot as 1000/Full fiber mode.
> 
> The network works perfectly in u-boot (dhcp, tftp of large files, ntp). Upon
> booting, kernel detects the link as 100/Full and no data can be exchanged over
> the interface.
> 
> As a quick fix, I tried setting .read_settings method of the 1145 driver to
> marvell_read_status (instead of genphy_read_status). Now the link is correctly
> detected as 1000/Full, but the data still can not be exchanged.
> 
> I assume, there's a configuration bit missing on the kernel side, as there are
> no such problems in u-boot.
> 

