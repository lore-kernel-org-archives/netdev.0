From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: inet6_connection_sock.h needs flowi
Date: Sun, 16 Oct 2011 20:13:10 -0400 (EDT)
Message-ID: <20111016.201310.2196482600418365872.davem@davemloft.net>
References: <1318671264-19684-1-git-send-email-christoph.paasch@uclouvain.be>
	<20111015.184126.53610934026688054.davem@davemloft.net>
	<4E9AA043.1090008@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab1JQAOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 20:14:23 -0400
In-Reply-To: <4E9AA043.1090008@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sun, 16 Oct 2011 12:13:39 +0300

> On 10/16/2011 01:41 AM, David Miller wrote:
>> From: Christoph Paasch<christoph.paasch@uclouvain.be>
>> Date: Sat, 15 Oct 2011 12:34:24 +0300
>>
>>> Otherwise we have a compiler-warning in c-files not including
>>> net/flow.h
>>> before inet6_connection_sock.h .
>>>
>>> Signed-off-by: Christoph Paasch<christoph.paasch@uclouvain.be>
>>
>> Example?  I've never seen this warning.
> 
> Currently, all the c-files that include inet6_connection_sock.h
> indirectly include flow.h before inet6_connection_sock.h. Thus
> currently there is no compiler-warning.

Then there is no bug you are fixing.
