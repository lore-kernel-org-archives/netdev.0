From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Mon, 28 Feb 2011 08:07:33 +0100
Message-ID: <20110228070732.GA2793@psychotron.redhat.com>
References: <4D690D16.8020503@gmail.com>
 <27369.1298749377@death>
 <20110227125816.GB2814@psychotron.redhat.com>
 <20110227.152208.102543719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, nicolas.2p.debian@gmail.com, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, andy@greyhouse.net,
	anna.fischer@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179Ab1B1HKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 02:10:04 -0500
Content-Disposition: inline
In-Reply-To: <20110227.152208.102543719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 28, 2011 at 12:22:08AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Sun, 27 Feb 2011 13:58:17 +0100
>
>> That is very true. And given that af_packet uses orig_dev to obtain
>> ifindex, it can be replaced by skb->skb_iif. That way we can get rid of
>> orig_dev parameter for good.
>
>I would rather see a complete patch set submitting at a unit, thanks.
>
>I've already marked your V3 last night as "changes requested" in
>patchwork for this reason.

That's a pity. V3 is complete patch. The changes we talk about in
discussion are just taking advantage of changes in patch V3. Would be in
my opinion better to apply V3 now and followup with the rest after that.
