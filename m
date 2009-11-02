From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Mon, 2 Nov 2009 13:02:23 +0000
Message-ID: <20091102130223.GB7790@ff.dom.local>
References: <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net> <20091102123029.GA7790@ff.dom.local> <20091102.043907.236634594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:42425 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705AbZKBNCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 08:02:20 -0500
Received: by fg-out-1718.google.com with SMTP id 19so21126fgg.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 05:02:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091102.043907.236634594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 04:39:07AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 2 Nov 2009 12:30:29 +0000
> 
> > Right, but it's not a 50% chance, I guess? A user most of the time
> > gets consistently multiqueue or non-multiqueue behavior after open,
> > unless I miss something. Then such an exceptional state could be
> > handled by real_num_tx_queues (just like in case of powered of cpus).
> > The main difference is to hold in num_tx_queues something that is
> > really available vs max possible value for all configs.
> 
> I see your point, yes this would seem to be a reasonable way
> to start handling num_tx_queues and real_num_tx_queues.

Very nice! So, I hope Eric should be satisfied with these requested
comments already :-)

Thanks everybody,
Jarek P.
