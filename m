From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13097] New: Kernel will freeze network after
 using a tun/tap device
Date: Wed, 15 Apr 2009 15:29:46 -0700
Message-ID: <20090415152946.90bbdfc0.akpm@linux-foundation.org>
References: <bug-13097-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org, maxk@qualcomm.com, vtun@office.satix.net,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52973 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbZDOWdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:33:14 -0400
In-Reply-To: <bug-13097-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Big fat regression!

On Wed, 15 Apr 2009 22:19:06 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13097
> 
>            Summary: Kernel will freeze network after using a tun/tap
>                     device
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.30-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: fragabr@gmail.com
>         Regression: Yes
> 
> 
> I choose the forcedeth driver to report this bug because I think it's related
> to forcedeth and not tun/tap driver, although I can be wrong.
> 
> With 2.6.29 kernel everything works fine, but with 2.6.30-rc2, a simple ping to
> a tun/tap device (for example ping to a vpn using openvpn) will freeze the
> network. In X I can't even use the keyboard anymore.
> 
> It just happens with a tun/tap device, not with a normal ethernet device or a
> normal internet connection.
> 
> If you think it's a tun/tap driver problem, please change the bug, but as I'm
> not completely sure, I choose forcedeth.

An obvious question would be: are you able to test the same setup with
a different type of network card?

