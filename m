From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Thu, 20 Sep 2012 15:41:03 -0400 (EDT)
Message-ID: <20120920.154103.310589245720062013.davem@davemloft.net>
References: <505AFDE9.4080602@earthlink.net>
	<1348141871.31352.66.camel@edumazet-glaptop>
	<505B5154.3020002@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sclark46@earthlink.net, brutus@google.com,
	edumazet@google.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102Ab2ITTlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 15:41:05 -0400
In-Reply-To: <505B5154.3020002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 20 Sep 2012 10:24:36 -0700

> On 09/20/2012 04:51 AM, Eric Dumazet wrote:
>> On Thu, 2012-09-20 at 07:28 -0400, Stephen Clark wrote:
>>>
>>> Does this mean traffic on the loopback interface will not traverse
>>> netfilter?
>>>
>>
>> Yes this was already mentioned.
>>
>> Only the SYN / SYNACK messages will
>>
>> All data will bypass IP stack, qdisc (if any), loopback driver, and
>> netfilter.
> 
> Does that then lift the tent flap for TOE?  As I recall, TOE's
> bypassing of all those things is one of the reasons used to reject
> TOE.

Wrong.  This bypassing is completely in software, and completely
controlled by us.

Which is completely opposite to TOE.

Don't spread fud like this, even on a whim.
