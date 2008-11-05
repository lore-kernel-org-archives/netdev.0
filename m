From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11955] New: WARNING: at
 net/sched/sch_generic.c:219 dev_watchdog+0x24b/0x25a()
Date: Wed, 05 Nov 2008 01:26:48 -0800 (PST)
Message-ID: <20081105.012648.197459483.davem@davemloft.net>
References: <bug-11955-10286@http.bugzilla.kernel.org/>
	<20081105010247.5e7d802c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	ralf.hildebrandt@charite.de, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753570AbYKEJ1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:27:14 -0500
In-Reply-To: <20081105010247.5e7d802c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 5 Nov 2008 01:02:47 -0800

> On Wed,  5 Nov 2008 00:38:10 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > Latest working kernel version: 2.6.27.3
> > Earliest failing kernel version: 2.6.27.4
> 
> A regression in -stable.

I personally suspect the pile of ACPI changes that went into 2.6.27.4

There is nothing in the networking bits that could have even remotely
caused this.
