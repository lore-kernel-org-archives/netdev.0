From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13397] New: forcedeth driver doesn't work
 during network boot
Date: Fri, 29 May 2009 14:31:46 -0700
Message-ID: <20090529143146.ba79428a.akpm@linux-foundation.org>
References: <bug-13397-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, rolf.fokkens@orange.nl,
	netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60858 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752486AbZE2Vbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 17:31:52 -0400
In-Reply-To: <bug-13397-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 28 May 2009 10:14:30 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13397
> 
>            Summary: forcedeth driver doesn't work during network boot
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: rolf.fokkens@orange.nl
>         Regression: No
> 
> 
> After installing Fedora 11-preview my diskless PC no longer boots. The initrd
> hangs when trying to bring te interface up. Remarkable is tha fact that de DHCP
> server (another Linux PC) registers a full DHCPDISCOVER, -OFFER, -REQUEST and
> -ACK sequence.
> 
> Before initrd tries te bring up the interface the BIOS does a PXE boot, which
> starts a gPXE image which starts the Fedora installation via grub over iscsi.
> 
> Both the BIOS PXE boot and the gPXE boot run without any trouble. Inird however
> hangs.
> 
> The used hardwars is a Asus M3N-VM MoBo with onboard ethernet device.
> 

