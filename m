From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add build-time checks for msg->msg_name
 size
Date: Sat, 18 Jan 2014 23:04:46 -0800 (PST)
Message-ID: <20140118.230446.447824561941914382.davem@davemloft.net>
References: <20140117215314.GC7562@noise.didjital.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: steffen@hurrle.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbaASHEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 02:04:49 -0500
In-Reply-To: <20140117215314.GC7562@noise.didjital.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Hurrle <steffen@hurrle.net>
Date: Fri, 17 Jan 2014 22:53:15 +0100

> This is a follow-up patch to f3d3342602f8bc ("net: rework recvmsg
> handler msg_name and msg_namelen logic").
> 
> DECLARE_SOCKADDR validates that the structure we use for writing the
> name information to is not larger than the buffer which is reserved
> for msg->msg_name (which is 128 bytes). Also use DECLARE_SOCKADDR
> consistently in sendmsg code paths.
> 
> Signed-off-by: Steffen Hurrle <steffen@hurrle.net>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks great, applied, thanks!
