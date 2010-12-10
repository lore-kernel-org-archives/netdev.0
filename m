From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 v2] ifb: use the lockless variants of skb_queue
Date: Fri, 10 Dec 2010 14:35:27 -0800 (PST)
Message-ID: <20101210.143527.241438724.davem@davemloft.net>
References: <1291510912-6979-1-git-send-email-xiaosuo@gmail.com>
	<1291559180.2159.683.camel@mojatatu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org, jarkao2@gmail.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752057Ab0LJWe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 17:34:59 -0500
In-Reply-To: <1291559180.2159.683.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 05 Dec 2010 09:26:20 -0500

> On Sun, 2010-12-05 at 09:01 +0800, Changli Gao wrote:
>> rq and tq are both protected by tx queue lock, so we can simply use
>> the lockless variants of skb_queue.
>> 
>> skb_queue_splice_tail_init() is used instead of the open coded and slow
>> one.
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

I've applied the most up to date versions of all 3 of
Changli's IFB patches, thanks!
