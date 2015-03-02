From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in
 sch_sfq
Date: Sun, 01 Mar 2015 23:06:41 -0500 (EST)
Message-ID: <20150301.230641.1074652099437388601.davem@davemloft.net>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	<1425247789-21211-7-git-send-email-therbert@google.com>
	<1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbbCBEGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 23:06:43 -0500
In-Reply-To: <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 01 Mar 2015 16:58:52 -0800

> On Sun, 2015-03-01 at 14:09 -0800, Tom Herbert wrote:
>> Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
>> jhash by hand.
> 
> This defeats one of the perturbation goal :
> 
> If two flows hashes into same hash, then skb_get_hash_perturb(skb,
> q->perturbation) will also give same hash forever and map to same hash
> bucket.

Yes, this needs to be resolved.
