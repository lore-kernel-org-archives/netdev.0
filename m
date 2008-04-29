From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] ARCH 2.6.24.y: Fix 32-bit x86 MSI-X allocation leakage
Date: Tue, 29 Apr 2008 12:22:35 +0200
Message-ID: <20080429102235.GI23198@elte.hu>
References: <20080426005950.7155.44626.stgit@scrappy.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34316 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753333AbYD2KWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 06:22:52 -0400
Content-Disposition: inline
In-Reply-To: <20080426005950.7155.44626.stgit@scrappy.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:

> This bug was introduced in the 2.6.24 i386/x86_64 tree merge, where 
> MSI-X vector allocation will eventually fail.  The cause is the new 
> bit array tracking used vectors is not getting cleared properly on IRQ 
> destruction on the 32-bit APIC code.

Greg, please fix the commit message - this is a separate bug that has 
nothing to do with the unification.

	Ingo
