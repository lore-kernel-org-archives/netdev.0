From: Brian Haley <brian.haley@hp.com>
Subject: Re: [IPV6] Fix ICMPv6 redirect handling with target multicast address
Date: Mon, 01 Oct 2007 13:36:24 -0400
Message-ID: <47013018.1020002@hp.com>
References: <46FD2B37.6040502@hp.com>	<OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com>	<20070929.100448.41933886.yoshfuji@linux-ipv6.org> <20071001.204921.52365121.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, dlstevens@us.ibm.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:52482 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761AbXJARgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 13:36:32 -0400
In-Reply-To: <20071001.204921.52365121.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

YOSHIFUJI Hideaki / 吉藤英明 wrote:
>>>         I think it'd also be better if you add the check to be:
>>>
>>>         if (ipv6_addr_type(target) & 
>>> (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST))
>>>
>>> or something along those lines, rather than reproducing ipv6_addr_type() 
>>> code
>>> separately in a new ipv6_addr_linklocal() function.
> 
> I'm fine with the idea of the fix itself.

Ok, in both the receive and send code?

> Please use ipv6_addr_type() so far and convert other users as well
> to ipv6_addr_linklocal() in another patch.

I'll re-do the patch.

-Brian
