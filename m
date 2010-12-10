From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] via-velocity: set sleep speed to 10Mbps for
 powersaving.
Date: Fri, 10 Dec 2010 12:47:42 -0800 (PST)
Message-ID: <20101210.124742.116394707.davem@davemloft.net>
References: <20101209092656.GA4064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, DavidLv@viatech.com.cn,
	ShirleyHu@viatech.com.cn, AndersMa@viatech.com.cn
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52305
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756855Ab0LJUrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 15:47:14 -0500
In-Reply-To: <20101209092656.GA4064@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 9 Dec 2010 10:26:56 +0100

> Signed-off-by: David Lv <DavidLv@viatech.com.cn>
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Please, no new module parameters that only have obscure meanings
on specific device types.

This is terrible for users.

I'm not applying these two patches, sorry.

I know it already has the 1000M one, and if I was handling driver patches
directly when that got in I apologize for not catching it, it's wrong too.

There is nothing that prevents adding ethtool facilities for this issue.

In fact looking at the via velocity driver options, many of them
completely duplicate existing ethtool mechanisms.  It's beyond a mess.

So I'm putting the line in the sand and will not allow new such options
to be added, sorry.
