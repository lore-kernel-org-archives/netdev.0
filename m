From: Andi Kleen <ak@muc.de>
Subject: Re: TCP prequeue performance
Date: Thu, 16 Jun 2005 02:23:59 +0200
Message-ID: <m17jgv9mjk.fsf@muc.de>
References: <BED5FA3B.2A0%cndougla@purdue.edu> <m1br679otj.fsf@muc.de>
	<20050615.164115.74747690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cndougla@purdue.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261681AbVFPAYF@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050615.164115.74747690.davem@davemloft.net> (David S.
 Miller's message of "Wed, 15 Jun 2005 16:41:15 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:
>
> Not true, if this check does not pass, tp->ucopy.task is
> never set, therefore prequeue processing is never performed.

Oh well, here goes my nice theory :)
>
> This test must pass the first time, when both tp->ucopy.task
> and user_recv are both NULL, in order for prequeue processing
> to occur at all.
>
> So his change did totally disable prequeue.

Then probably his test was latency bound somehow, but normally
that should not affect system time, just wall time.

I would perhaps compare context switch numbers and netstat -s
output between the different runs and see if anything pops out.

-Andi
