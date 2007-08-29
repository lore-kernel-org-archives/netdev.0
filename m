From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 16:31:36 -0700
Message-ID: <46D601D8.5070409@hp.com>
References: <46D5F32F.2070502@hp.com>	<20070829.153503.18295527.davem@davemloft.net>	<46D5FBF3.5050700@hp.com> <20070829.161528.38309258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:40588 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753467AbXH2XcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 19:32:04 -0400
In-Reply-To: <20070829.161528.38309258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
>>The trace I've been sent shows clean RTTs ranging from ~200 milliseconds 
>>to ~7000 milliseconds.
> 
> 
> Thanks for the info.
> 
> It's pretty easy to generate examples where we might have some sockets
> talking over interfaces on such a network and others which are not.
> Therefore, if we do this, a per-route metric is probably the best bet.

FWIW, the places where I've seen this come-up thusfar are where we have 
a sort of "gateway" or front-end system which is connected on one side 
to the cellphone network with the bad delays, and on the other side is 
connected to an internal network where actual losses leading to RTO's 
are epsilon.  Certainly something which could make a per-route decision 
would work there and probably quite well, though a simple sysctl does 
seem to be sufficient and would touch fewer places.

Do you think it is still worthwhile for me to rework the initial patch 
to use CTL_UNNUMBERED?

rick
