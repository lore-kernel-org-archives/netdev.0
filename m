From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Mon, 23 Jun 2008 21:18:35 +0200
Message-ID: <485FF70B.6010001@trash.net>
References: <20080623174702.GD4756@cs181140183.pp.htv.fi> <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59771 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbYFWTSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 15:18:40 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
>> Commit d62733c8e437fdb58325617c4b3331769ba82d70
>> ([SCHED]: Qdisc changes and sch_rr added for multiqueue)
>> added a NET_SCH_RR option that was unused since the code
>> went unconditionally into sch_prio.
> 
> I don't agree we should remove this option, purely for the fact that
> there isn't any way a user would know the qdisc existed without reading
> the code.  I'd rather see a change to sch_prio.c to correctly wrap the
> RR code, which I should have done in the first place.  My hurdle is when
> the module is selected, NET_SCH_RR isn't defined to be used as an #ifdef
> check in the code.  Only when it's selected to be built-in is the symbol
> defined.  If I can get around that, I'll generate a patch to properly
> wrap sch_prio.c code.  I know I'm missing something silly, so any
> guidance is appreciated.

For modular selected options, the name is <name>_MODULE (so
CONFIG_NET_SCH_RR_MODULE in this case).

I tend to agree with Adrian though, this option doesn't
provide any value.
