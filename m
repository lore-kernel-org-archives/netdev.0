From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11648] New: rtl8150 module does not unload
 when interface is up
Date: Thu, 2 Oct 2008 17:38:29 -0700
Message-ID: <20081002173829.082fd922.akpm@linux-foundation.org>
References: <bug-11648-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, vapier@gentoo.org
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40471 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753983AbYJCAif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 20:38:35 -0400
In-Reply-To: <bug-11648-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 25 Sep 2008 13:52:44 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11648
> 
>            Summary: rtl8150 module does not unload when interface is up
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.26.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: vapier@gentoo.org
> 
> 
> using stock kernel.org 2.6.26.5 on a Dell Latitude D820 laptop (running Gentoo,
> but shouldnt matter).
> 
> i'm using a RTL8150 USB NIC with the driver built as a module:
> ID 0bda:8150 Realtek Semiconductor Corp. RTL8150 Fast Ethernet Adapter
> 
> if you load the module, then bring up the interface by doing something simple
> like `ifconfig eth1 192.168.0.1`, then do `rmmod rtl8150`, the driver goes to
> lunch and forgets to come back.  top shows ksoftirqd processing a lot and rmmod
> using 100% cpu.  trying to strace rmmod shows nothing, so something in the
> kernel is processing a lot on its behalf ...
> 

I never know who to blame^Wconsult when it comes to USB net drivers.
