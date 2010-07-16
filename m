From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] net: bridge: fix sign bug
Date: Thu, 15 Jul 2010 20:28:53 -0700 (PDT)
Message-ID: <20100715.202853.233710023.davem@davemloft.net>
References: <1279219653-12791-1-git-send-email-segooon@gmail.com>
	<20100715122144.0f2cf5cf@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segooon@gmail.com, kernel-janitors@vger.kernel.org,
	herbert@gondor.hengli.com.au, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935392Ab0GPD2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:28:38 -0400
In-Reply-To: <20100715122144.0f2cf5cf@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 15 Jul 2010 12:21:44 -0700

> On Thu, 15 Jul 2010 22:47:33 +0400
> Kulikov Vasiliy <segooon@gmail.com> wrote:
> 
>> ipv6_skip_exthdr() can return error code that is below zero.
>> 'offset' is unsigned, so it makes no sense.
>> ipv6_skip_exthdr() returns 'int' so we can painlessly change type of
>> offset to int.
>> 
>> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
...
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
