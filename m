From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/5] bridge: RCU annotation and cleanup
Date: Mon, 15 Nov 2010 08:19:27 -0800
Message-ID: <20101115081927.0fd8e614@nehalam>
References: <20101114211201.678755903@vyatta.com>
	<201011152123.HHB21896.HFOOVSMFOtLJQF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47931 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932388Ab0KOQTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 11:19:30 -0500
In-Reply-To: <201011152123.HHB21896.HFOOVSMFOtLJQF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Nov 2010 21:23:37 +0900
Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> > +			rp = rcu_dereference(hlist_next_rcu(rp->next));  
> 
> I think this one is hlist_next_rcu(rp).

Yes, you are correct.

-- 
