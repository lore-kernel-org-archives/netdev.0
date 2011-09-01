From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 42132] New: Support BCM5750M in tg3
Date: Thu, 1 Sep 2011 16:40:11 -0700
Message-ID: <20110901164011.baa9a8b8.akpm@linux-foundation.org>
References: <bug-42132-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, Benjamin Li <benli@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, stack.box@gmail.com
To: netdev@vger.kernel.org, Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46532 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932536Ab1IAXkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 19:40:46 -0400
In-Reply-To: <bug-42132-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 31 Aug 2011 18:18:40 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=42132
> 
>            Summary: Support BCM5750M in tg3
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: stack.box@gmail.com
>         Regression: Yes
> 
> 
> I have a notebook (HP TC4400) which has a BCM5750 ethernet card inside. The
> ouput of lspci is:
> 
> 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme BCM5750M
> Gigabit Ethernet [14e4:167c]
> 
> Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the support for this
> device.
> 

67b284d476bcb3d100 says "These devices were never released to the public".

> I wish to have the support for this network card back again. Thanks!

oops ;)
