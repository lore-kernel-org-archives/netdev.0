From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12860] New: SO_RCVBUF and SO_SNDBUF must be
 set before connect() or listen()
Date: Thu, 12 Mar 2009 13:13:06 -0700
Message-ID: <20090312131306.260cf3ff.akpm@linux-foundation.org>
References: <bug-12860-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, cristiklein@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41743 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751793AbZCLUOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 16:14:11 -0400
In-Reply-To: <bug-12860-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 12 Mar 2009 10:23:52 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12860
> 
>            Summary: SO_RCVBUF and SO_SNDBUF must be set before connect() or
>                     listen()
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.18
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: cristiklein@gmail.com
> 
> 
> Problem Description:
> 
> Calling setsockopt() with SO_RCVBUF or SO_SNDBUF after connect() or listen()
> makes sockets have a horrible performance. Moreover, getsockopt() returns
> values as if the previous setsockopt() was successful.
> 
> Solution:
> 
> 1) Document this somewhere in the man-pages (e.g. socket(7))
> 2) Make setsockopt() fail after connect() or listen()
> 
> If you need an example code, I'll be happy to provide it.
> 

