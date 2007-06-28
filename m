From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 18:53:18 +0200
Message-ID: <4683E77E.6070108@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0391@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54952 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761646AbXF1QyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 12:54:13 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329031F0391@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
> Thanks for fixing; however, the current sch_prio doesn't unregister the
> qdisc if register_qdisc() on prio fails, or does that happen implicitly
> because the module will probably unload?


It failed, there's nothing to unregister. But when you register two
qdiscs and the second one fails you have to unregister the first one.

Your way works too, but it might fail registering the second one without
providing any feedback to the user.
