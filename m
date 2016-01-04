From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 5 Jan 2016 00:51:37 +0100
Message-ID: <568B0589.9010900@stressinduktion.org>
References: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
 <1451946988.8255.78.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S370tAh1g5q9trDuFxc84qOozT6XjdSKB94dvGRTUikfvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56250 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753421AbcADXvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 18:51:40 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id B040D2071C
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 18:51:39 -0500 (EST)
In-Reply-To: <CALx6S370tAh1g5q9trDuFxc84qOozT6XjdSKB94dvGRTUikfvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.01.2016 00:34, Tom Herbert wrote:
> On Mon, Jan 4, 2016 at 2:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Sun, 2016-01-03 at 15:22 -0800, Tom Herbert wrote:
>> \...
>>> +402: /* Length 2, align is 1, 3, or 5 */
>>> +     movb    (%rdi), %al
>>> +     movb    1(%rdi), %ah
>>
>> Looks like a movw (%rdi),%ax
>>
> Wouldn't that be an unaligned access?

Based on my knowledge (based on arch/x86/include/asm/unaligned.h) the 
x86 architecture (and this code is specific for x86) can handle 
unaligned access on its own.

Bye,
Hannes
