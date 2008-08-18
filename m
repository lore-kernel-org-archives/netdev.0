From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 0/9]: Killing qdisc->ops->requeue().
Date: Mon, 18 Aug 2008 09:21:38 +0000
Message-ID: <20080818092138.GD5434@ff.dom.local>
References: <20080818.013640.254202527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:3255 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbYHRJVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 05:21:45 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2105091fkq.5
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 02:21:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.013640.254202527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 01:36:40AM -0700, David Miller wrote:
> 
> This implements what I tried to describe in previous
> emails.
> 
> It gets rid of qdisc->ops->requeue() because logically it
> is completely superfluous.  All it does is allow the
> next level to declare to the lower qdisc "send this next
> no matter what" and we can trivially do that with a simple
> list.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

David, I hope these patches are right, anyway I think I'll be able
to look at them later, after I figure out these new locking changes.
Of course, you don't need to wait for me.

But, I guess, much more important should be Patrick's opinion on
this, so I added him to CC. 

Thanks,
Jarek P.
