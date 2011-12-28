From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] inet_diag: Extend the meminfo report
Date: Wed, 28 Dec 2011 14:02:27 -0500 (EST)
Message-ID: <20111228.140227.1047349775267791507.davem@davemloft.net>
References: <4EFB1BE0.1020305@parallels.com>
	<20111228.134553.1005758963166343587.davem@davemloft.net>
	<4EFB66F1.3020702@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab1L1TCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 14:02:30 -0500
In-Reply-To: <4EFB66F1.3020702@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 28 Dec 2011 22:58:57 +0400

> On 12/28/2011 10:45 PM, David Miller wrote:
>> From: Pavel Emelyanov <xemul@parallels.com>
>> Date: Wed, 28 Dec 2011 17:38:40 +0400
>> 
>>> Add the backlog length and wmem and rmem buffers limits.
>>> With this the TCP memory info is full and can be analyzed.
>>>
>>> Few words about extending the existing structure. The nla engine stores lengths of
>>> fields and the nla parser will parse the new format successfully (checked on the ss
>>> tool). But new apps will have to take this field's length into account. Hopefully
>>> this is acceptable price for not introducing another ext bit and structure.
>>>
>>> Singed-off-by: Pavel Emelyanov <xemul@parallels.com>
>> 
>> I think you'll need to add a new extension, rather than create this incompatability.
>> 
> 
> OK, I will, but I seem to misunderstand the NLA's length value then. My impression is
> that it was introduced to make it possible to put the payload of different length,
> probably adding more stuff at the end.

It's to validate that the object inside the attribute has the expected length.
