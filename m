From: David Miller <davem@davemloft.net>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Thu, 11 Jun 2015 00:16:07 -0700 (PDT)
Message-ID: <20150611.001607.1734541690877787503.davem@davemloft.net>
References: <1433856864.19447.25.camel@infradead.org>
	<1433897347.27504.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<1433982688.3907.7.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, johannes@sipsolutions.net,
	torvalds@linux-foundation.org, marcel@holtmann.org,
	sfeldma@gmail.com, netdev@vger.kernel.org, teg@jklm.no
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbbFKHQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:16:08 -0400
In-Reply-To: <1433982688.3907.7.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 11 Jun 2015 01:31:28 +0100

> On Tue, 2015-06-09 at 17:49 -0700, Eric Dumazet wrote:
>> > I've added some debugging, and it seems that when it deadlocks, glibc
>> > doesn't get *any* response to its RTM_GETADDR request. I know we'd get
>> > ENOBUFS is a *response* was dropped... but what about when the request
>> > itself is dropped? ... 
>> 
>> Please check that this patch fixes your issue :
>> 
>> http://patchwork.ozlabs.org/patch/473041/
> 
> Looks likely; thanks. I'm running with that patch now. I haven't been
> able to quickly reproduce the problem on demand, but it usually happens
> within a day or two. So it'll be a few days at least before I call it a
> success.

Yeah, and I just sent that to -stable just over a day ago.
