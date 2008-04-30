From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Tue, 29 Apr 2008 17:16:23 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32904FE0E37@orsmsx414.amr.corp.intel.com>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com> <20080429102107.GH23198@elte.hu> <D5C1322C3E673F459512FB59E0DDC32904F9F13E@orsmsx414.amr.corp.intel.com> <20080429151403.GA19410@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <torvalds@linux-foundation.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "Rusty Russell" <rusty@rustcorp.com.au>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17509 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754459AbYD3AQV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 20:16:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080429151403.GA19410@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> that change came in via lguest (commit dbeb2be2), not the 
> 32-bit/64-bit
> x86 unification. Lguest is a new feature in 2.6.24 and this 
> side-effect of it was not known until you fixed it - thanks for that!
> 
> So i was just splitting hairs over your statement that it was 
> due to the unification :-)

100% agree.  Thanks for making sure about the distinction.

> 
> 	Ingo
> 
