From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] netdevice ops
Date: 19 May 2007 16:18:02 +0200
Message-ID: <p737ir4ew2t.fsf@bingen.suse.de>
References: <20070517210737.17d88401@localhost> <464D3175.8050007@pobox.com>
	<20070517.220529.115910791.davem@davemloft.net>
	<20070517225833.1b7e6acf@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41736 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757465AbXESNVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2007 09:21:06 -0400
In-Reply-To: <20070517225833.1b7e6acf@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:
> 
> I would think a non-conditional deref would be easily pipelined.
> If the net_device struct was more cache dense, it probably would
> even out.

It might be a good idea to consider strategic prefetch points for it.

e.g. TCP executes quite a lot of code until it finally decides to dev_queue_xmit.
Prefetching before that might be a good idea.

-Andi
