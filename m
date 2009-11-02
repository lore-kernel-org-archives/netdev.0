From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] multiqueue changes
Date: Mon, 02 Nov 2009 04:39:07 -0800 (PST)
Message-ID: <20091102.043907.236634594.davem@davemloft.net>
References: <20091101132017.GA2598@ami.dom.local>
	<20091102.033533.08766686.davem@davemloft.net>
	<20091102123029.GA7790@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54039
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754826AbZKBMim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 07:38:42 -0500
In-Reply-To: <20091102123029.GA7790@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 2 Nov 2009 12:30:29 +0000

> Right, but it's not a 50% chance, I guess? A user most of the time
> gets consistently multiqueue or non-multiqueue behavior after open,
> unless I miss something. Then such an exceptional state could be
> handled by real_num_tx_queues (just like in case of powered of cpus).
> The main difference is to hold in num_tx_queues something that is
> really available vs max possible value for all configs.

I see your point, yes this would seem to be a reasonable way
to start handling num_tx_queues and real_num_tx_queues.
