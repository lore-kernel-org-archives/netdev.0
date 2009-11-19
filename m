From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: dont leak skbs in ieee802154_fake_xmit()
Date: Thu, 19 Nov 2009 12:27:57 -0800 (PST)
Message-ID: <20091119.122757.232578204.davem@davemloft.net>
References: <4B052BCA.4020901@gmail.com>
	<bc64b4640911190757w7eea481sd346085e3ceb1276@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754955AbZKSU1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 15:27:40 -0500
In-Reply-To: <bc64b4640911190757w7eea481sd346085e3ceb1276@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Thu, 19 Nov 2009 18:57:48 +0300

> On Thu, Nov 19, 2009 at 2:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> ieee802154_fake_xmit() should free skbs since it returns NETDEV_TX_OK
> 
> Acked-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> 
> David, please apply.

Applied.
