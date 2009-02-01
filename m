From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: What should PCI core do during suspend-resume? (was: Re:
 2.6.29-rc3: tg3 dead after resume)
Date: Sat, 31 Jan 2009 17:13:40 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311709140.3067@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901311516360.2978@localhost.localdomain> <alpine.LFD.2.00.0901311534340.3067@localhost.localdomain> <200902010136.55375.rjw@sisk.pl>
 <alpine.LFD.2.00.0901311652500.3067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45824 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752744AbZBABNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 20:13:54 -0500
In-Reply-To: <alpine.LFD.2.00.0901311652500.3067@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Linus Torvalds wrote:
> 
> I thought the _DSW thing is common for setting up wakeup, but _PSx is not. 
> But I have not looked at many ACPI tables in my life. I try to active 
> avoid it if I at all humanly can.

Doing a quick grep on my laptop seems to confirm that. No actual _PSx 
things found in any acpi tables at all that I can see.

And on a mac mini, there are _PS3 entries that _look_ like they are 
connected to the IDE controller and the realtime clock, but it looks like 
they don't happen for the PCI devices.

But again - I may have screwed that up. ACPI tables are not my favourite 
data structure.

		Linus
