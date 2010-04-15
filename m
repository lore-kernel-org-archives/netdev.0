From: David Miller <davem@davemloft.net>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 01:50:05 -0700 (PDT)
Message-ID: <20100415.015005.156280476.davem@davemloft.net>
References: <1271268242.16881.1719.camel@edumazet-laptop>
	<1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, xiaosuo@gmail.com,
	andi@firstfloor.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757513Ab0DOIuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:50:00 -0400
In-Reply-To: <20100414124426.6aee95c3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 14 Apr 2010 12:44:26 -0700

> On Wed, 14 Apr 2010 14:53:42 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
>> Agreed. So to enumerate, the benefits come in if:
>> a) you have many processors
>> b) you have single-queue nic
>> c) at sub-threshold traffic you dont care about a little latency
> 
> There probably needs to be better autotuning for this, there is no reason
> that RPS to be steering packets unless the queue is getting backed up.

I disagree, if the goal is to migrate the bulk of packet processing
to where the app will actually sink and process the data then it should
forward to RPS marked cpus regardless of local queue levels.

