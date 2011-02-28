From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 27 Feb 2011 23:30:13 -0800 (PST)
Message-ID: <20110227.233013.226766890.davem@davemloft.net>
References: <20110227125816.GB2814@psychotron.redhat.com>
	<20110227.152208.102543719.davem@davemloft.net>
	<20110228070732.GA2793@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, nicolas.2p.debian@gmail.com, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	anna.fischer@hp.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752377Ab1B1H3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 02:29:37 -0500
In-Reply-To: <20110228070732.GA2793@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 28 Feb 2011 08:07:33 +0100

> Mon, Feb 28, 2011 at 12:22:08AM CET, davem@davemloft.net wrote:
>>From: Jiri Pirko <jpirko@redhat.com>
>>Date: Sun, 27 Feb 2011 13:58:17 +0100
>>
>>> That is very true. And given that af_packet uses orig_dev to obtain
>>> ifindex, it can be replaced by skb->skb_iif. That way we can get rid of
>>> orig_dev parameter for good.
>>
>>I would rather see a complete patch set submitting at a unit, thanks.
>>
>>I've already marked your V3 last night as "changes requested" in
>>patchwork for this reason.
> 
> That's a pity. V3 is complete patch. The changes we talk about in
> discussion are just taking advantage of changes in patch V3. Would be in
> my opinion better to apply V3 now and followup with the rest after that.

Fair enough, I'll aply it now, thanks.
