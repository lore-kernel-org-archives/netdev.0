From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] udp: bind() optimisation
Date: Tue, 10 Nov 2009 22:32:19 -0800 (PST)
Message-ID: <20091110.223219.214776568.davem@davemloft.net>
References: <4AF834A9.2050005@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lgrijincu@ixiacom.com, opurdila@ixiacom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752729AbZKKGbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:31:53 -0500
In-Reply-To: <4AF834A9.2050005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Nov 2009 16:26:33 +0100

> UDP bind() can be O(N^2) in some pathological cases.
> 
> Thanks to secondary hash tables, we can make it O(N)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
