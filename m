From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 02/10] net: Add queue state xoff flag for stack
Date: Tue, 29 Nov 2011 12:27:46 -0500 (EST)
Message-ID: <20111129.122746.246022903745748780.davem@davemloft.net>
References: <alpine.DEB.2.00.1111281816540.24308@pokey.mtv.corp.google.com>
	<1322572371.2090.1.camel@mojatatu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: jhs@mojatatu.com, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab1K2R14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 12:27:56 -0500
In-Reply-To: <1322572371.2090.1.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 29 Nov 2011 08:12:51 -0500

> On Mon, 2011-11-28 at 18:32 -0800, Tom Herbert wrote:
>>  
>>  enum netdev_queue_state_t {
>> -       __QUEUE_STATE_XOFF,
>> +       __QUEUE_STATE_DRV_XOFF,
>> +       __QUEUE_STATE_STACK_XOFF,
>>         __QUEUE_STATE_FROZEN,
> 
> QUEUE_STATE_DRV_XOFF seems to be a rename of __QUEUE_STATE_XOFF
> no issues there.
> Is inserting __QUEUE_STATE_STACK_XOFF going to cause any issues?
> Typically, you should insert new things at the end.

I doubt the ordering matters here, and any such dependency is a bug.
:-)
