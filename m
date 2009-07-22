From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in back trace (regression)
Date: Wed, 22 Jul 2009 13:45:57 -0700
Message-ID: <20090722134557.2457c5f5.akpm@linux-foundation.org>
References: <bug-13760-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: for.poige+bugzilla.kernel.org@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50536 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752886AbZGVUq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 16:46:29 -0400
In-Reply-To: <bug-13760-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 11 Jul 2009 06:10:00 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13760
> 
>            Summary: 2.6.30 kernel locks up with pppoe in back trace
>                     (regression)
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
>         ReportedBy: for.poige+bugzilla.kernel.org@gmail.com
>         Regression: Yes
> 
> 
> Having updated kernel to 2.6.30 (and 2.6.30.1) I've faced several lock-ups
> during boot sequence (and even during shutdown), when pppoe connection had been
> initiated (and interrupted on shutdown). The lock-ups aren't Alt_SysRq_B
> breakable.
> 
> I still not have backtraces saved but as soon as pppoe connection initiation
> runs before running X-server (and after its shutdown), I have seen parts of
> dmesg's output and to my surprise it was regarding pppoe's functions.
> 

This regression report is nearly two weeks old and I think there has
been a bit of ppp-related fixing going on in that time.

Can you please tell us whether the regression is still present in
2.6.30.2?  If so, I expect we'll be wanting to see those traces, 
please.

Thanks.
