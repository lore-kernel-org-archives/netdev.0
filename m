From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 15 Jun 2009 02:02:40 -0700 (PDT)
Message-ID: <20090615.020240.84385988.davem@davemloft.net>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	<20090610.012342.121254416.davem@davemloft.net>
	<65634d660906142252y6f7fc021l844b172995c10044@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38895
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758276AbZFOJCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 05:02:37 -0400
In-Reply-To: <65634d660906142252y6f7fc021l844b172995c10044@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 14 Jun 2009 22:52:13 -0700

>> Just to keep this topic alive, I want to mention two things:
>>
>> 1) Just the other day support for the IXGBE "Flow Director" was
>>   added to net-next-2.6, it basically does flow steering in
>>   hardware.  It remembers where the last TX for a flow was
>>   made, and steers RX traffic there.
>>
> 
> That's very cool.  Is this able to preserve in order delivery?

I don't know how the hardware works to this level of detail,
sorry.  But yet that's a very important issue.

> What is the advantage over using a shared skbuff queue and making
> doing a single IPI to schedule the backlog device on the remote CPU?

No locking.  Queue is only ever accessed by the local cpu.
