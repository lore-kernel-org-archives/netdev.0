From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 20:24:00 +0200
Message-ID: <466D9340.6050706@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290303AB41@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48833 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbXFKS0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:26:34 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290303AB41@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Another question is what to do about other hard_start_xmit callers.
>>Independant of which field is used, should the classification 
>>that may have happend on a different device be retained (TC 
>>actions again)?
> 
> 
> [...] Either way, before it gets enqueued through
> dev_queue_xmit(), the value will get cleared, so having an artifact
> laying around won't be possible.


You're right, I was thinking of a case where a packet would
be redirected from a multiqueue device to another one and
then not go through dev_queue_xmit but some other path to
hard_start_xmit that doesn't update the classification.
But there is no case like this.

