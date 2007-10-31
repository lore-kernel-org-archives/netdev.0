From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9269] New: bonding module cannot enslave
 ethernet devices provided by sunhme
Date: Wed, 31 Oct 2007 15:37:32 -0700
Message-ID: <20071031153732.cb950b28.akpm@linux-foundation.org>
References: <bug-9269-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, dev-null@telus.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47278 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752289AbXJaWiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 18:38:06 -0400
In-Reply-To: <bug-9269-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 14:35:56 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9269
> 
>            Summary: bonding module cannot enslave ethernet devices provided
>                     by sunhme
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.18-3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: dev-null@telus.net
> 
> 
> Most recent kernel where this bug did not occur: N/A
> Distribution: Debian 4.0r1/stable (Etch)
> Hardware Environment: Sun Netra T1 105 (sparc64)
> Software Environment:
> Problem Description:
> bonding module cannot enslave ethernet devices provided by sunhme - link
> status is never reported via netif_carrier_on/netif_carrier_off which makes
> sunhme not usable as a slave to the bonding module
> 
> Steps to reproduce:
> modprobe sunhme
> modprobe bonding
> ifconfig bond0 up
> ifconfig eth0 up
> # wait for link to be up
> ifenslave bond0 eth0
> # bond0 never comes up and keeps waiting for link
> 
