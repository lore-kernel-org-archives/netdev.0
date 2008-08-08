From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 12:32:53 -0700
Message-ID: <20080808193252.GD607@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <200808082109.47284.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16401 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751450AbYHHTcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 15:32:54 -0400
Content-Disposition: inline
In-Reply-To: <200808082109.47284.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 12:09:46PM -0700, Wolfgang Walter wrote:
> I don't know though why kernel_fpu_begin exactly fixes the problem:

because it prevents taking a DNA fault inside the kernel (resulting
in TS_USEDFPU not set).

> 
> Maybe preemption must be disabled when padlocks RNG, ACE, Hash-engine etc. is
> used. Maybe just some barrier is needed which preempt_disable provides.

problem can happen even when preemption is disabled.

> What should I do now?

I will post your fix(including the other usages) with the appropriate changelog
shortly.

thanks,
suresh
