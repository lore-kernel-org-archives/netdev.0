From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: locking api self-test hanging
Date: Mon, 04 Feb 2008 14:14:52 +0100
Message-ID: <1202130892.32654.81.camel@lappy>
References: <20080203150246.50647fa4.akpm@linux-foundation.org>
	 <20080203150744.cf7d0415.akpm@linux-foundation.org>
	 <20080204044304.d244e761.akpm@linux-foundation.org>
	 <20080204050421.0febc754.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Bernhard Walle <bwalle@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43041 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbYBDNPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 08:15:08 -0500
In-Reply-To: <20080204050421.0febc754.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-02-04 at 05:04 -0800, Andrew Morton wrote:

> After disabling both CONFIG_DEBUG_LOCKING_API_SELFTESTS and netconsole
> (using current mainline) I get a login prompt, and also...

> [    7.819146] WARNING: at kernel/lockdep.c:2033 trace_hardirqs_on+0x9b/0x10d()

> That warning in lockdep.c should have a comment explaining to readers under
> which circumstances it will trigger, and what they did wrong.  In fact if
> I've interpreted it correctly I don't see why it's a DEBUG_LOCKS_WARN_ON
> thing at all?  It should be a first-class lockdep warning?

Agreed, I'll make lockdep print a nice error.

