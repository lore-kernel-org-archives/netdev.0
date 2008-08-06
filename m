From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Wed, 6 Aug 2008 13:14:02 -0700
Message-ID: <20080806201401.GA607@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200807301411.01622.wolfgang.walter@stwm.de> <20080806103354.GA31623@gondor.apana.org.au> <200808061933.25631.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"Siddha, Suresh B" <suresh.b.siddha@intel.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21127 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758306AbYHFUOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 16:14:04 -0400
Content-Disposition: inline
In-Reply-To: <200808061933.25631.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 10:33:25AM -0700, Wolfgang Walter wrote:
> Hello Herbert,
> 
> I think I finally found the problem.
> 
> Here a short description again: all our routers with a via C3 using padlock for AES-encryption are
> crashing with 2.6.26 while they work fine with 2.6.25. Not using padlock
> (i.e. using the i386 assembler version of AES) they just work fine.

Both the padlock version or asm version don't use FP/math registers, right?
It is interesting that you don't see the problem with asm version
but see the problem with padlock version.

Does disabling CONFIG_PREEMPT in 2.6.26 change anything? And also,
can you provide the complete kernel log till the point of failure(oops
that you sent doesn't have the call trace info)

thanks,
suresh
