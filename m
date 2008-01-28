From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9836] New: e1000 network driver doesn't
 recognize (and load on) its hardware
Date: Mon, 28 Jan 2008 13:44:04 -0800
Message-ID: <20080128134404.24c80ce7.akpm@linux-foundation.org>
References: <bug-9836-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	t.artem@mailcity.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60209 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751836AbYA1Vo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 16:44:26 -0500
In-Reply-To: <bug-9836-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jan 2008 05:32:00 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9836
> 
>            Summary: e1000 network driver doesn't recognize (and load on) its
>                     hardware
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: t.artem@mailcity.com
> 
> 
> Latest working kernel version: not known
> Earliest failing kernel version: every
> Distribution: Fedora Core 7
> Hardware Environment: lspci output and dmesg information are attached
> Software Environment: doesn't matter
> Problem Description: recently e1000 network drivers stopped working when right
> after switching on or rebooting our Intel server. While trying to 'modprobe
> e1000; ifconfig eth0 IP_address' I've got a failure and e1000 says hardware is
> not detected. After about a *hundred* attempts to modprobe and rmmod it, the
> e1000 network driver finally loads and allows to set up networking.
> 
> Steps to reproduce: reboot or power on your server. Try to up the network which
> is attached to your Intel PCI-X Pro 1000 NIC.
> 

Odd.
