From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Mon, 23 Jun 2008 14:52:31 -0700 (PDT)
Message-ID: <20080623.145231.223738833.davem@davemloft.net>
References: <20080623174702.GD4756@cs181140183.pp.htv.fi>
	<D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, kaber@trash.net, netdev@vger.kernel.org,
	rpjday@crashcourse.ca
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750766AbYFWVwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 17:52:31 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 23 Jun 2008 11:31:30 -0700

> >Commit d62733c8e437fdb58325617c4b3331769ba82d70
> >([SCHED]: Qdisc changes and sch_rr added for multiqueue)
> >added a NET_SCH_RR option that was unused since the code
> >went unconditionally into sch_prio.
> 
> I don't agree we should remove this option, purely for the fact that
> there isn't any way a user would know the qdisc existed without reading
> the code.

That's not how config options work.

We add features and facilities all the time that lack CONFIG
option entries.

And frankly, I plan on removing the RR scheduler in the TX
multiqueue bits I'm doing.

But even if I didn't plan this, we should remove these unused
CONFIG variables, because that is our tree wide policy.  We
don't use them as dinky knobs for documentation.

