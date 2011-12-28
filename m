From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 3/5] inet_diag: Extend the meminfo report
Date: Wed, 28 Dec 2011 22:58:57 +0400
Message-ID: <4EFB66F1.3020702@parallels.com>
References: <4EFB1BE0.1020305@parallels.com> <20111228.134553.1005758963166343587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47133 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754119Ab1L1S7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 13:59:03 -0500
In-Reply-To: <20111228.134553.1005758963166343587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2011 10:45 PM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Wed, 28 Dec 2011 17:38:40 +0400
> 
>> Add the backlog length and wmem and rmem buffers limits.
>> With this the TCP memory info is full and can be analyzed.
>>
>> Few words about extending the existing structure. The nla engine stores lengths of
>> fields and the nla parser will parse the new format successfully (checked on the ss
>> tool). But new apps will have to take this field's length into account. Hopefully
>> this is acceptable price for not introducing another ext bit and structure.
>>
>> Singed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> I think you'll need to add a new extension, rather than create this incompatability.
> 

OK, I will, but I seem to misunderstand the NLA's length value then. My impression is
that it was introduced to make it possible to put the payload of different length,
probably adding more stuff at the end.

If I'm wrong about it, what is the real purpose of this field? _Only_ to make nla_parse
jump on the "generic" offsets?

Thanks,
Pavel
