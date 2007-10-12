From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9149] New: accept() doesn't wake with error
 when socket descriptor closed
Date: Fri, 12 Oct 2007 10:06:45 -0700
Message-ID: <20071012100645.64dc1afd.akpm@linux-foundation.org>
References: <bug-9149-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: mkielar@go2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49624 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932660AbXJLRGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 13:06:55 -0400
In-Reply-To: <bug-9149-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 07:42:06 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9149
> 
>            Summary: accept() doesn't wake with error when socket descriptor
>                     closed
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
>         ReportedBy: mkielar@go2.pl
> 
> 
> Most recent kernel where this bug did not occur: no idea
> Distribution: no idea - remote server
> Hardware Environment: i686
> Software Environment: no idea - probably pure console server
> 
> Problem Description:
> In multithreaded process, one thread launches accept() on a valid-so-far
> listening socket file descriptor sockfd and waits on it. After this second
> thread launches close( sockfd ). First thread further waits on accept() even
> though the descriptor is now invalid. accept() should wake up and return with
> -1 and errno EBADF.
> 

I have a feeling this is an FAQ, but I forget what the answer is?
