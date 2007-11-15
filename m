From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9386] New: sis190 network driver crash
Date: Thu, 15 Nov 2007 11:58:41 -0800
Message-ID: <20071115115841.30d43003.akpm@linux-foundation.org>
References: <bug-9386-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, chris@linuxepos.com,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34804 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757856AbXKOT7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 14:59:24 -0500
In-Reply-To: <bug-9386-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 07:30:53 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9386
> 
>            Summary: sis190 network driver crash
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.23.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: chris@linuxepos.com
>                 CC: romieu@fr.zoreil.com
> 
> 
> I have a problem where I can lock up a number of machines by 
> changing the link state on a sis190 Ethernet port. For example, during 
> a data transfer such as FTP if I unplug the Ethernet cable and plug it 
> back in, the Ethernet interface will stop responding and the machine 
> will lock up after a minute or so. This behaviour is repeatable. I have the
> sis190 driver loaded as a module.
> 
> I haven't found a kernel version where this doesn't happen. It happens with
> kernel 2.6.20.15, for example.
> 
