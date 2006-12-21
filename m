From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7724] New: asm/types.h should define __u64 if
 isoc99
Date: Thu, 21 Dec 2006 12:49:54 -0800
Message-ID: <20061221124954.6bb415e9.akpm@osdl.org>
References: <200612211617.kBLGHAAg028181@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, uberlord@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:39247 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423085AbWLUUuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 15:50:10 -0500
To: netdev@vger.kernel.org
In-Reply-To: <200612211617.kBLGHAAg028181@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Dec 2006 08:17:10 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7724
> 
>            Summary: asm/types.h should define __u64 if isoc99
>     Kernel Version: 2.6.19
>             Status: NEW
>           Severity: blocking
>              Owner: other_other@kernel-bugs.osdl.org
>          Submitter: uberlord@gentoo.org
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> Distribution: Gentoo
> Hardware Environment: n/a
> Software Environment: 2.6.18 kernels and lower
> Problem Description:
> 
> Steps to reproduce:
> Download dhcpcd-3.0.7 from http://dhcpcd.berlios.de/
> extract it and type 'make'
> Watch it fail with this error
> cc -D_BSD_SOURCE -O2 -pipe -pedantic -std=c99 -Wall -Wunused -Wimplicit
> -Wshadow -Wformat=2 -Wmissing-declarations -Wno-missing-prototypes
> -Wwrite-strings -Wbad-function-cast -Wnested-externs -Wcomment -Winline
> -Wchar-subscripts -Wcast-align -Wno-format-nonliteral -Wsequence-point -Wextra
> -Wdeclaration-after-statement -c interface.c
> In file included from /usr/include/linux/rtnetlink.h:5,
>                  from interface.c:33:
> /usr/include/linux/if_link.h:43: error: expected specifier-qualifier-list
> before ___u64_
> In file included from /usr/include/linux/rtnetlink.h:7,
>                  from interface.c:33:
> /usr/include/linux/neighbour.h:92: error: expected specifier-qualifier-list
> before ___u64_
> make: *** [interface.o] Error 1
> 


