From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pkt_sched: fq: avoid hang when quantum 0
Date: Wed, 04 Feb 2015 20:08:07 -0800 (PST)
Message-ID: <20150204.200807.1562005793209207889.davem@davemloft.net>
References: <1422982158-12530-1-git-send-email-kennetkl@ifi.uio.no>
	<1422985569.907.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kennetkl@ifi.uio.no, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbBEEIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 23:08:10 -0500
In-Reply-To: <1422985569.907.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Feb 2015 09:46:09 -0800

> On Tue, 2015-02-03 at 17:49 +0100, Kenneth Klette Jonassen wrote:
>> Configuring fq with quantum 0 hangs the system, presumably because of a
>> non-interruptible infinite loop. Either way quantum 0 does not make sense.
>> 
>> Reproduce with:
>> sudo tc qdisc add dev lo root fq quantum 0 initial_quantum 0
>> ping 127.0.0.1
>> 
>> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
