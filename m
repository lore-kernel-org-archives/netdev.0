From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Mon, 28 Apr 2008 14:21:26 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904F9ED1F@orsmsx414.amr.corp.intel.com>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> <alpine.LFD.1.10.0804282216570.3261@apollo.tec.linutronix.de> <D5C1322C3E673F459512FB59E0DDC32904F9EC8C@orsmsx414.amr.corp.intel.com> <alpine.LFD.1.10.0804282313040.3261@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	<netdev@vger.kernel.org>
To: "Thomas Gleixner" <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26957 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932846AbYD1VVZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 17:21:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <alpine.LFD.1.10.0804282313040.3261@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ok, that makes sense. I just did not get the context out of 
> your commit log. Adding the commit which caused the trouble 
> to the commit log makes it easier to understand. So the 
> problem is unrelated to the merger, it's caused by a patch 
> which was pending against the i386 tree around the time of 
> the merger and which was converted to the merge tree.

That's my miss for not including the specific context.  I will try to be
better about that in the future.  I do appreciate the interest though to
make sure it's specifically understood when this bug was introduced.

Cheers,

-PJ Waskiewicz
