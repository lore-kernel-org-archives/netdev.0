From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix tcp_mark_head_lost() with packets == 0
Date: Fri, 19 Mar 2010 22:44:57 -0700 (PDT)
Message-ID: <20100319.224457.179950657.davem@davemloft.net>
References: <1268828189-22182-1-git-send-email-lennart.schulte@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	hannemann@nets.rwth-aachen.de
To: lennart.schulte@nets.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751349Ab0CTFof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 01:44:35 -0400
In-Reply-To: <1268828189-22182-1-git-send-email-lennart.schulte@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Date: Wed, 17 Mar 2010 13:16:29 +0100

> A packet is marked as lost in case packets == 0, although nothing should be done.
> This results in a too early retransmitted packet during recovery in some cases.
> This small patch fixes this issue by returning immediately.
> 
> Signed-off-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

Applied, thanks.
