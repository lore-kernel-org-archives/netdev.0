From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 21:22:22 -0800 (PST)
Message-ID: <20101129.212222.115953137.davem@davemloft.net>
References: <AANLkTimwo_ok=1dfzOST=rKqQdNS95wUAVdrrZHBMddS@mail.gmail.com>
	<20101129.191457.193722052.davem@davemloft.net>
	<AANLkTin11AYaFWMArC6fNQnvej2+=WUfOtTVrtX8WLEZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771Ab0K3FVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 00:21:55 -0500
In-Reply-To: <AANLkTin11AYaFWMArC6fNQnvej2+=WUfOtTVrtX8WLEZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 30 Nov 2010 12:51:08 +0800

> On Tue, Nov 30, 2010 at 11:14 AM, David Miller <davem@davemloft.net> wrote:
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Tue, 30 Nov 2010 10:33:49 +0800
>>
>>> I have thought about converting this AVL tree to rbtree. When I saw
>>> the comment above, I gave it up, because rbtree makes this structure
>>> bigger. If ipv6 support is added, I think it is time to turn to
>>> rbtree. :)
>>
>> If it takes size over 128 bytes, it is probably still a bad idea.
>> Right now it is just under 128.
>>
> 
> Why 128? The current size of inet_peer is 64 bytes, and after your
> ipv6 patch, it is just 80. And, inet_peer is allocated from its own
> mem_cache, so the size of the memory for it should not be aligned to
> 2^n.

Sorry, I was taking into the consideration other work I am doing
which will move all of the routing metrics into inet_peer as well.

With ipv6 address support, it fits perfectly into 128 bytes on
64-bit.
