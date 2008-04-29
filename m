From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] ARCH: Fix 32-bit x86 MSI-X allocation leakage
Date: Tue, 29 Apr 2008 12:21:07 +0200
Message-ID: <20080429102107.GH23198@elte.hu>
References: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:44454 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976AbYD2KVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 06:21:22 -0400
Content-Disposition: inline
In-Reply-To: <20080426005850.7098.77479.stgit@scrappy.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com> wrote:

> This bug was introduced in the 2.6.24 i386/x86_64 tree merge, [...]

that's wrong, that code was there in v2.6.23 too - and it wasnt touched 
in the unification. Why do you think it was introduced in the 
i386/x86_64 tree merge?

... the fix is right though, thanks!
 
	Ingo
