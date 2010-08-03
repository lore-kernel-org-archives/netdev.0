From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16503] New: Upgrade to 2.6.34.2 breaks
 ethernet network
Date: Tue, 3 Aug 2010 13:27:40 -0700
Message-ID: <20100803132740.946cf78a.akpm@linux-foundation.org>
References: <bug-16503-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>, stable@kernel.org,
	davemorgan353@btinternet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35834 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757674Ab0HCU2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 16:28:52 -0400
In-Reply-To: <bug-16503-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 3 Aug 2010 20:14:34 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16503
> 
>            Summary: Upgrade to 2.6.34.2 breaks ethernet network
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: davemorgan353@btinternet.com
>         Regression: No
> 
> 
> Using Arch Linux with fully up-to-date system.
> 
> Upgrading kernel from 2.6.34.1 to 2.6.34.2 breaks my ethernet connection.  I
> get dhcp timeouts but no errors in the logs regarding the kernel or the card.
> 
> Dell Inspiron 1720.
> 
> 03:00.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX (rev
> 02)
> 
> Downgrading the kernel fixes the issue.
> 

There are no changes to b44.c in patch-2.6.34.2.  Perhaps you could
generate the dmesg logs for 2.6.34.1 and 2.6.34.2 and run `diff -u'
against them, see if anything interesting pops out?

