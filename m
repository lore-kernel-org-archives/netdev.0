From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bridge: remove dev_put() in add_del_if()
Date: Thu, 05 Nov 2009 21:07:56 -0800 (PST)
Message-ID: <20091105.210756.06389264.davem@davemloft.net>
References: <4AF1D153.5040309@gmail.com>
	<20091104114020.5a2aef2c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52464
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750805AbZKFFHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:07:31 -0500
In-Reply-To: <20091104114020.5a2aef2c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Nov 2009 11:40:20 -0800

> On Wed, 04 Nov 2009 20:09:07 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> add_del_if() is called with RTNL, we can use __dev_get_by_index()
>> instead of [dev_get_by_index() + dev_put()]
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> 
> As part of the general ref count purge sure.
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks everyone.
