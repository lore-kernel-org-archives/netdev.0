From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] tcp_diag: Don't report max ack backlog in wqueue
Date: Wed, 28 Dec 2011 13:43:22 -0500 (EST)
Message-ID: <20111228.134322.2072620295557335734.davem@davemloft.net>
References: <4EFB1B5C.2070005@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab1L1SnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:43:25 -0500
In-Reply-To: <4EFB1B5C.2070005@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 28 Dec 2011 17:36:28 +0400

> This is not correct and actually makes ss work differently on proc
> vs netlink -- in the former case 0 is reported.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

It's very much intentional Pavel, Alexey Kuznetsov put this there on
purpose.

There is no other place in the diag interface where the
max_ack_backlog value is provided.

I'm not applying this.
