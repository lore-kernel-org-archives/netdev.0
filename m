From: David Miller <davem@davemloft.net>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 00:35:06 -0700 (PDT)
Message-ID: <20091013.003506.67125018.davem@davemloft.net>
References: <20091013050705.GA2194@1wt.eu>
	<4AD42B0F.8010809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756675AbZJMHfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:35:10 -0400
In-Reply-To: <4AD42B0F.8010809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Oct 2009 09:23:59 +0200

> I dont understand why you want to decrement rskq_defer_accept here.
> We receive a pure ACK (wihout DATA).
> We should receive exactly one such ACK.
> (This is the third packet of the three way TCP handshake)
> 
> How this can solve the problem you mention ?
> (ie, not sending an RST when we timeout the SYN_RECV session)

I'll hold off on this patch until Eric's comments are
addressed, thanks.
