From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9940] New: e1000e driver with 82566DM-2
 controller doesn't strip crc from frames
Date: Tue, 12 Feb 2008 02:12:34 -0800
Message-ID: <20080212021234.a3ad5d93.akpm@linux-foundation.org>
References: <bug-9940-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	johan.andersson@transmode.se
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50192 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762045AbYBLKNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 05:13:54 -0500
In-Reply-To: <bug-9940-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Feb 2008 01:50:49 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9940
> 
>            Summary: e1000e driver with 82566DM-2 controller doesn't strip
>                     crc from frames
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: johan.andersson@transmode.se
> 
> 
> Latest working kernel version: n/a
> Earliest failing kernel version: 2.6.24
> Distribution: Gentoo 2007.0
> Hardware Environment: HP Compaq dc7800p
> Software Environment: n/a
> Problem Description:
> The e1000e driver doesn't strip the ethernet frame crc is used with the
> 82566DM-2 chip.
> This will result, among other things, that bridging doesn't work together with
> this chip.
> Reverting commit 140a74802894e9db57e5cd77ccff77e590ece5f3 fixes this issue but
> has performance implications.
> 
> Steps to reproduce:
> Send a ping and monitor the responce with tcpdump.
> 

