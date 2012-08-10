From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] codel: refine one condition to avoid a nul rec_inv_sqrt
Date: Fri, 10 Aug 2012 17:16:11 +0200
Message-ID: <1344611771.31104.2716.camel@edumazet-glaptop>
References: <1343631141.2626.13293.camel@edumazet-glaptop>
	 <20120730.145412.1689803770003231369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lp2s1h@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46116 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572Ab2HJPQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 11:16:16 -0400
Received: by bkwj10 with SMTP id j10so639098bkw.19
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 08:16:15 -0700 (PDT)
In-Reply-To: <20120730.145412.1689803770003231369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-30 at 14:54 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 30 Jul 2012 08:52:21 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > One condition before codel_Newton_step() was not good if
> > we never left the dropping state for a flow. As a result
> > rec_inv_sqrt was 0, instead of the ~0 initial value.
> > 
> > codel control law was then set to a very aggressive mode, dropping
> > many packets before reaching 'target' and recovering from this problem.
> > 
> > To keep codel_vars_init() as efficient as possible, refine
> > the condition to make sure rec_inv_sqrt initial value is correct
> > 
> > Many thanks to Anton Mich for discovering the issue and suggesting
> > a fix.
> > 
> > Reported-by: Anton Mich <lp2s1h@gmail.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied and queued up for -stable.

Hi David, I think this patch got lost somehow ?

Thanks
