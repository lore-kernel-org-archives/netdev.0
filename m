From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Mon, 19 Oct 2009 21:28:55 -0700 (PDT)
Message-ID: <20091019.212855.179405364.davem@davemloft.net>
References: <4ADD3794.8030906@gmail.com>
	<20091019.212018.79580287.davem@davemloft.net>
	<4ADD3B5A.1080905@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751058AbZJTE2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:28:32 -0400
In-Reply-To: <4ADD3B5A.1080905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Oct 2009 06:23:54 +0200

> I wonder if the whole thing could use RCU somehow, since some
> workloads hit this dev_base_lock rwlock pretty hard...

True, but for now we'll put your fix in :-)
