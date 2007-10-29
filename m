From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9260] New: tipc_config.h is not installed when
 doing "make headers_install"
Date: Mon, 29 Oct 2007 12:07:16 -0700
Message-ID: <20071029120716.4957ded1.akpm@linux-foundation.org>
References: <bug-9260-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, linux@izac.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39865 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750841AbXJ2THw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 15:07:52 -0400
In-Reply-To: <bug-9260-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007 09:10:26 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9260
> 
>            Summary: tipc_config.h is not installed when doing "make
>                     headers_install"
>            Product: Other
>            Version: 2.5
>      KernelVersion: 2.6.23.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Configuration
>         AssignedTo: zippel@linux-m68k.org
>         ReportedBy: linux@izac.de
> 
> 
> Most recent kernel where this bug did not occur: 2.6.15.7
> Distribution: all
> Hardware Environment: all
> Software Environment: all
> 
> Problem Description:
> When doing "make headers_install" the file tipc_config.h is not installed. It
> describes the interface to configure the TIPC module and it is needed when
> building the config utility (tipc-config). 
> Adding the following line to include/linux/Kbuild solves this:
> header-y += tipc_config.h
> 
> Steps to reproduce: make headers_install
> 
