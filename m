From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13589] New: usbnet and /proc/net/dev stats
Date: Mon, 29 Jun 2009 17:23:41 -0700
Message-ID: <20090629172341.50bce90f.akpm@linux-foundation.org>
References: <bug-13589-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>, bjk@luxsci.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54516 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752548AbZF3AYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 20:24:09 -0400
In-Reply-To: <bug-13589-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 20 Jun 2009 16:24:13 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13589
> 
>            Summary: usbnet and /proc/net/dev stats
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: bjk@luxsci.net
>         Regression: No
> 
> 
> Commit 805aaa29fa breaks device statistics with the usbnet module. Reverting
> this commit fixes it. I think usbnet needed this callback to lookup the dev so
> it could update .stats.
> 
> Also, I do have CONFIG_COMPAT_NET_DEV_OPS defined and am using usbnet with
> cdc_ether and zaurus.
> 

This has turned into a bit of a mess, as the fix which I typed in needs
the revert of another patch, and I don't know what actually went wrong
with usbnet stats anyway.

Could someone (Stephen?) please take a look?

As it appears to be a 2.6.29->2.6.30 regression, please remember to cc
stable@kernel.org on any fixes, thanks.

