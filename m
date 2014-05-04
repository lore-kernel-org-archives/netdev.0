From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: "conntrack zones" support for defrag user check
 in ip_expire
Date: Sun, 04 May 2014 14:28:24 -0400 (EDT)
Message-ID: <20140504.142824.1212392577822772638.davem@davemloft.net>
References: <536426BC.7020509@parallels.com>
	<20140504111850.GA3765@localhost>
	<20140504125835.GA4452@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vvs@parallels.com, kaber@trash.net, fw@strlen.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbaEDS20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 14:28:26 -0400
In-Reply-To: <20140504125835.GA4452@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 4 May 2014 14:58:35 +0200

> On Sun, May 04, 2014 at 01:18:50PM +0200, Pablo Neira Ayuso wrote:
>> On Sat, May 03, 2014 at 03:14:04AM +0400, Vasily Averin wrote:
>> > Defrag user check in ip_expire was not updated after adding support for
>> > "conntrack zones"
>> 
>> I think this bug manifests as a RFC violation, as the router will send
>> the icmp time exceeeded message when using conntrack zones. Just would
>> like to confirm this, so we can include it in the patch description.
>> Thanks.
> 
> @David: If no objection, I'll pick this patch given that it's a
> netfilter bug.
> 
> I will also append to the patch description the comment above for the
> record.

That's perfectly fine, thanks.
