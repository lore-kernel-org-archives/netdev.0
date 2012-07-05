From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/5] rtcache remove respin
Date: Thu, 05 Jul 2012 21:03:37 +0200
Message-ID: <1341515017.3265.6.camel@edumazet-glaptop>
References: <20120701.050243.908285695895815999.davem@davemloft.net>
	 <1341225841.5269.69.camel@edumazet-glaptop>
	 <20120705.031539.2275742387594459652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65196 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab2GETDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 15:03:42 -0400
Received: by werb14 with SMTP id b14so5563367wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 12:03:41 -0700 (PDT)
In-Reply-To: <20120705.031539.2275742387594459652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 03:15 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 Jul 2012 12:44:01 +0200
> 
> > If we still want __refcnt being on cache line boundary, we might find a
> > better way to accomplish this.
> 
> Back to this issue again.
> 
> Eric, if you take a look at net-next right now, I left a dummy padding
> in dst_entry where the neighbour pointer used to be.
> 
> Can you come up with some way to make use of that new space?
> 

If route cache is removed, I believe we can remove all paddings.

Each tcp session will have its own dst_entry, instead of being shared.
