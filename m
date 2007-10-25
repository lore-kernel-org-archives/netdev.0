From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9225] New: typhoon : "no descs for cmd, had
 (needed) 0 (1) cmd, 31 (7) resp"
Date: Thu, 25 Oct 2007 13:20:16 -0700
Message-ID: <20071025132016.b6f8ce45.akpm@linux-foundation.org>
References: <bug-9225-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, sanarin@nikiet.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51202 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762727AbXJYUUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 16:20:22 -0400
In-Reply-To: <bug-9225-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Oct 2007 06:45:42 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9225
> 
>            Summary: typhoon : "no descs for cmd, had (needed) 0 (1) cmd, 31
>                     (7) resp"
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.23.1 SMP PREEMPT
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: sanarin@nikiet.ru
> 
> 
> Most recent kernel where this bug did not occur: none
> Distribution: Fedora Core 4
> Hardware Environment: Intel 845 chipset, 3 x 3C990-FX-97 NICs
> Software Environment:
> Problem Description:
>  Our dmesg buffer fill of these messages
> 
> eth1: no descs for cmd, had (needed) 0 (1) cmd, 31 (7) resp
> eth1: error getting stats
> eth1: no descs for cmd, had (needed) 0 (1) cmd, 31 (7) resp
> eth1: error getting stats
> eth1: no descs for cmd, had (needed) 0 (1) cmd, 31 (7) resp
> eth1: error getting stats
> 
> and so one.
> 
>  After for days of working we got kernel panic.
> 
> Steps to reproduce:

(switching to email - please respond via reply-to-all, not via the bugzilla
web interface)

typhoon.c doesn't appear to have a maintainer.  

It oopsed in typhoon_rx - there's a jpg attached to the bugzilla report.
