From: David Miller <davem@davemloft.net>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Sat, 05 Jan 2008 20:15:49 -0800 (PST)
Message-ID: <20080105.201549.184458758.davem@davemloft.net>
References: <477ECCD7.8090905@katalix.com>
	<20080104.232504.238436937.davem@davemloft.net>
	<p738x348kpq.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753479AbYAFEPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 23:15:50 -0500
In-Reply-To: <p738x348kpq.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 05 Jan 2008 14:29:05 +0100

> In 2.4 we used to have (haven't checked recently) performance regressions
> with NAPI vs non NAPI (or versus the old BCM vendor driver) on tg3 for
> some workloads that didn't fully fill the link. The theory was always
> that the reason for that was something like the regular switching in
> and out. So I think we saw that problem on tg3 too.

It was because we originally didn't program the HW interrupt
mitigation settings at all when using NAPI, now we do and the problem
is long gone.
