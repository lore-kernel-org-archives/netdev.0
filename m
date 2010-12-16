From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ifb: fix a lockdep splat
Date: Thu, 16 Dec 2010 14:55:26 -0800 (PST)
Message-ID: <20101216.145526.191400391.davem@davemloft.net>
References: <1292493175.2883.56.camel@edumazet-laptop>
	<AANLkTinbeR68+BsHYC-0yMAkbZ20TS1EiSg=cGHKQ-f2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751309Ab0LPWy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:54:57 -0500
In-Reply-To: <AANLkTinbeR68+BsHYC-0yMAkbZ20TS1EiSg=cGHKQ-f2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 16 Dec 2010 18:00:50 +0800

> On Thu, Dec 16, 2010 at 5:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> After recent ifb changes, we must use lockless __skb_dequeue() since
>> lock is not anymore initialized.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
>> Cc: Changli Gao <xiaosuo@gmail.com>
> 
> Acked-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
