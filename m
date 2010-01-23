From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] extend RTM_GETNEIGH to allow getting more precise
 information
Date: Sat, 23 Jan 2010 02:12:33 -0800 (PST)
Message-ID: <20100123.021233.122638456.davem@davemloft.net>
References: <201001151842.59813.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ixlk-cr@farscape.ixiacom.com,
	pchakrabarti@ixiacom.com
To: cratiu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754709Ab0AWKMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:12:22 -0500
In-Reply-To: <201001151842.59813.cratiu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Fri, 15 Jan 2010 18:42:59 +0200

> Please have a look at this patch which tries to solve a problem we 
> encountered.
> 
> The background is that RTM_GETNEIGH netlink message is used to get a complete 
> dump of a neighbor table. Sometimes, that's too much (especially when you have 
> a lot of neighbors). This patch allows one to specify the IPv4/6 address of a 
> neighbor and the device index through which it is accessible in order to 
> obtain only that entry.
> 
> If you have other suggestions on how to accomplish this task, please let us 
> know.

Please add a netlink attribute to specify lookup keys.

Adding specifiers to the end of the existing request message
error prone and creates trouble in the future if someone gets
the idea to add something more.

