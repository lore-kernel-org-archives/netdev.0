From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 24472] New: Kernel panic - not syncing: Fatal
 Exception
Date: Wed, 8 Dec 2010 12:22:33 -0800
Message-ID: <20101208122233.835a4997.akpm@linux-foundation.org>
References: <bug-24472-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl
To: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47771 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755395Ab0LHUX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:23:27 -0500
In-Reply-To: <bug-24472-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 8 Dec 2010 20:14:45 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=24472
> 
>            Summary: Kernel panic - not syncing: Fatal Exception
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: pstaszewski@artcom.pl
>         Regression: No
> 
> 
> Created an attachment (id=39332)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=39332)
> Kernel Panic
> 
> Hello i have problems with ppp driver and pppoe
> I have random kernel panics
> 
> In attached image is Call Trace from panic.
> 
> 

ppp_unregister_channel() appears to be using a bad pointer.
