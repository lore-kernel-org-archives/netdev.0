From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Thu, 19 Dec 2013 14:48:58 -0500 (EST)
Message-ID: <20131219.144858.1284652650622247805.davem@davemloft.net>
References: <1387096221-20112-1-git-send-email-vtlam@google.com>
	<20131219.143045.472862795767521855.davem@davemloft.net>
	<1387482036.19078.371.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vtlam@google.com, netdev@vger.kernel.org, nanditad@google.com,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218Ab3LSTtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:49:01 -0500
In-Reply-To: <1387482036.19078.371.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Dec 2013 11:40:36 -0800

> On Thu, 2013-12-19 at 14:30 -0500, David Miller wrote:
>> From: Terry Lam <vtlam@google.com>
>> Date: Sun, 15 Dec 2013 00:30:21 -0800
>> 
>> > This patch implements the first size-based qdisc that attempts to
>> > differentiate between small flows and heavy-hitters.  The goal is to
>> > catch the heavy-hitters and move them to a separate queue with less
>> > priority so that bulk traffic does not affect the latency of critical
>> > traffic.  Currently "less priority" means less weight (2:1 in
>> > particular) in a Weighted Deficit Round Robin (WDRR) scheduler.
>> 
>> Can someone please review this, thanks!
> 
> 
> I did, and somehow managed to not send the message :
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
