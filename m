From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist outgoing
 interface
Date: Mon, 02 Jun 2008 13:39:06 -0400
Message-ID: <4844303A.7090909@hp.com>
References: <20080602.172009.84304151.yoshfuji@linux-ipv6.org>	<4843B65C.1060702@cn.fujitsu.com>	<48441C82.1070609@hp.com> <20080603.014105.73332390.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:13616 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758596AbYFBRjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 13:39:09 -0400
In-Reply-To: <20080603.014105.73332390.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / 吉藤英明 wrote:
>> In the current git tree, this :: address is going to turn-into ::1, so 
>> the ifindex is irrelevant, the packet will be looped-back.  Older 
>> kernels could transmit the packet on the wire using the default route. 
>> Can you elaborate on the problem you were seeing?
> 
> Confused.  We are not talking about destination address but source
> address, right?

I was testing with both set to :: to see if the source address was ever
getting transmitted as ::, but only noticed the destination address was
on an older kernel.  That was my confusion, but there is still some bug
here.

-Brian
