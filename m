From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: update the netstamp_needed counter when cloning
 sockets
Date: Fri, 08 Jan 2010 00:00:34 -0800 (PST)
Message-ID: <20100108.000034.48682320.davem@davemloft.net>
References: <1262732790-16053-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48133
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab0AHIA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:00:26 -0500
In-Reply-To: <1262732790-16053-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed,  6 Jan 2010 01:06:30 +0200

> This fixes a netstamp_needed accounting issue when the listen socket
> has SO_TIMESTAMP set:
> 
>     s = socket(AF_INET, SOCK_STREAM, 0);
>     setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, 1); -> netstamp_needed = 1
>     bind(s, ...);
>     listen(s, ...);
>     s2 = accept(s, ...); -> netstamp_needed = 1
>     close(s2); -> netstamp_needed = 0
>     close(s); -> netstamp_needed = -1
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied and queued up for -stable, thanks for fixing this!
