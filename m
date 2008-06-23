From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Mon, 23 Jun 2008 11:31:30 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com>
References: <20080623174702.GD4756@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: "Adrian Bunk" <bunk@kernel.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16405 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758486AbYFWSbg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 14:31:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080623174702.GD4756@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Commit d62733c8e437fdb58325617c4b3331769ba82d70
>([SCHED]: Qdisc changes and sch_rr added for multiqueue)
>added a NET_SCH_RR option that was unused since the code
>went unconditionally into sch_prio.

I don't agree we should remove this option, purely for the fact that
there isn't any way a user would know the qdisc existed without reading
the code.  I'd rather see a change to sch_prio.c to correctly wrap the
RR code, which I should have done in the first place.  My hurdle is when
the module is selected, NET_SCH_RR isn't defined to be used as an #ifdef
check in the code.  Only when it's selected to be built-in is the symbol
defined.  If I can get around that, I'll generate a patch to properly
wrap sch_prio.c code.  I know I'm missing something silly, so any
guidance is appreciated.

-PJ Waskiewicz
