From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Wed, 31 Jul 2013 12:01:26 -0700 (PDT)
Message-ID: <20130731.120126.2193837817631047825.davem@davemloft.net>
References: <1375118644.10515.18.camel@edumazet-glaptop>
	<20130730.191138.420648092010563209.davem@davemloft.net>
	<20130731174854.GA27714@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, luis.henriques@canonical.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, jcliburn@gmail.com
To: benjamin.poirier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab3GaTB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 15:01:27 -0400
In-Reply-To: <20130731174854.GA27714@d2.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <benjamin.poirier@gmail.com>
Date: Wed, 31 Jul 2013 13:48:54 -0400

> On 2013/07/30 19:11, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 29 Jul 2013 10:24:04 -0700
>> 
>> > [PATCH] atl1c: use custom skb allocator
>> > 
> 
> BTW, this didn't end up in git with the intended patch subject. The
> extra text prepended in the email also made it to the log.
> 
> 7b70176 atl1c: Fix misuse of netdev_alloc_skb in refilling rx ring

I know, I realized this when I sent the pull request to Linus.

Eric, your patch submission format is extremely error prone for me
sometime.  When you submit patches in email thread, and do things like
you did here, it causes problems sometimes.

Really just send it in the usual way, with the real Subject line
matching the commit message header line you wish to use etc.

Thanks!
