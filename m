From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/11] netpoll: get rid of name parameter
Date: Mon, 19 Nov 2007 19:49:30 -0800 (PST)
Message-ID: <20071119.194930.81940823.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184338.799390572@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48976
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751961AbXKTDtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 22:49:31 -0500
In-Reply-To: <20071103184338.799390572@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:21 -0700

> The name was being stored and used only for error messages.
> The same effect can be had by just passing it in where needed during
> config.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

The whole world of netpoll is not netconsole even though it just
happens to be that way currently.  Otherwise we can just eliminate
the modularity completely and merge all of netconsole into
net/core/netpoll.c but of course we won't do that.

If another user of netpoll comes by we'll just have to add this thing
back again.

I'm dropping this patch.
