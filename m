From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] u32: negative offset fix
Date: Mon, 02 Aug 2010 22:08:08 -0700 (PDT)
Message-ID: <20100802.220808.235685948.davem@davemloft.net>
References: <20100802220030.991706005@vyatta.com>
	<20100802164413.6f327ce6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751074Ab0HCFHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:07:50 -0400
In-Reply-To: <20100802164413.6f327ce6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 2 Aug 2010 16:44:13 -0700

> It was possible to use a negative offset in a u32 match to reference
> the ethernet header or other parts of the link layer header.
> This fixes the regression caused by:
> 
> commit fbc2e7d9cf49e0bf89b9e91fd60a06851a855c5d
> Author: Changli Gao <xiaosuo@gmail.com>
> Date:   Wed Jun 2 07:32:42 2010 -0700
> 
>     cls_u32: use skb_header_pointer() to dereference data safely
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
