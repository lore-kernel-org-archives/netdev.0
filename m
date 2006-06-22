From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6730] New: pptp connection hang on heavy
 network load.
Date: Thu, 22 Jun 2006 03:15:10 -0700
Message-ID: <20060622031510.79d725e7.akpm@osdl.org>
References: <200606221006.k5MA60v2020594@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1984 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751559AbWFVKPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 06:15:44 -0400
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	wizard580@gmail.com
In-Reply-To: <200606221006.k5MA60v2020594@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jun 2006 03:06:00 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=6730
> 
>            Summary: pptp connection hang on heavy network load.
>     Kernel Version: 2.6.17
>             Status: NEW
>           Severity: blocking
>              Owner: acme@conectiva.com.br
>          Submitter: wizard580@gmail.com
> 
> 
> Most recent kernel where this bug did not occur: 2.6.17
> Distribution: debian
> Hardware Environment: NVidia nForce2 GF6600 forcedeth driver.
> Software Environment: latest debian sid dist-upgrade on 22 june 2006
> Problem Description: when I make a many files (about 500 files near 1 Gb of total size, 
> *.deb from last and previous upgrade for example ) upload to a server via ssh/scp, my vpn 
> pptp connection hangs till i restart ppp connection. This problem persist not only a latest 
> kernel. I don't remember when it begin to hangs. It very-very annoying and makes me 
> difficult to make my daily job. If I do not make such "heavy" network vpn traffic, I can 
> work for a weeks without reboots and any problems
> 
> Steps to reproduce:
> Start to copy big amount of data over pptp connection from a client linux machine. Ex. via 
> ssh/scp.
> 

We thought we'd fixed this :(
