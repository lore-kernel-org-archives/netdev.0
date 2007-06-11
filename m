From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 20:07:15 +0200
Message-ID: <466D8F53.6090308@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290303AB0B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48502 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbXFKSJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:09:47 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290303AB0B@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>BTW, I couldn't find anything but a single 
>>netif_wake_subqueue in your (old) e1000 patch. Why doesn't it 
>>stop subqueues?
> 
> 
> A previous e1000 patch stopped subqueues.  The last e1000 patch I sent
> to the list doesn't stop them, and that's a problem with that patch; it
> was sent purely to show how the alloc_etherdev_mq() stuff worked, but I
> missed the subqueue control.  I can fix that and send an updated patch
> if you'd like.  The reason I missed it is we maintain an out-of-tree
> driver and an in-tree driver, and mixing/matching code between the two
> becomes a bit of a juggling act sometimes when doing little engineering
> snippits.
> 
> Thanks for reviewing these.  I'll repost something with updates from
> your feedback.


Thanks, I do have some more comments, but a repost with the patches
split up in infrastructure changes, qdisc changes one patch per qdisc
and the e1000 patch would make that easier.
