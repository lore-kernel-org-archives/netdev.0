From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 20772] New: ip= nfsaddrs= stopped working
Date: Tue, 19 Oct 2010 12:09:38 -0700
Message-ID: <20101019120938.93622e82.akpm@linux-foundation.org>
References: <bug-20772-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mpetersen@peak6.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44603 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754807Ab0JSTKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 15:10:31 -0400
In-Reply-To: <bug-20772-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 19 Oct 2010 18:20:15 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=20772
> 
>            Summary: ip= nfsaddrs= stopped working
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.33, 2.6.32, 2.6.26
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: mpetersen@peak6.com
>         Regression: Yes
> 
> 
> I can no longer set a static IP address using either ip= or nfsaddr=, ie
> ip=192.168.0.42:192.168.0.69:255.255.255.0:testhost:eth0:none has no effect,
> and DHCP is still attempted.
> 
> Even if I undefine IP_PNP_DHCP IP_PNP_BOOTP and IP_PNP_RARP in the config (but
> leave IP_PNP,) the kernel seems to ignore the static IP settings and try to get
> a an IP address with DHCP somehow.
> 

