From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: mmotm 2008-11-26-17-00 uploaded
Date: Thu, 4 Dec 2008 06:42:06 +0900
Message-ID: <200812040642.FFB65682.QSVJMHOOFLtFOF@I-love.SAKURA.ne.jp>
References: <200811270101.mAR114rp016378@imap1.linux-foundation.org>
	<200811282209.FDC95384.tLQJFOFOHFMSOV@I-love.SAKURA.ne.jp>
	<20081128114257.a651b9ee.akpm@linux-foundation.org>
	<20081203075254.3bcb3220@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com, akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755613AbYLCVmW@vger.kernel.org>
In-Reply-To: <20081203075254.3bcb3220@extreme>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Stephen Hemminger wrote:
> > > [   24.978638] BUG: unable to handle kernel NULL pointer dereference at 00000004
> > > [   24.980541] IP: [<c056bfb7>] loopback_get_stats+0x26/0x51
> > 
> > At a guess I'd say that local variable `stats' in loopback_get_stats()
> > is null.
> > 
> > but it's a bit hard to see how that change could cause the crash which
> > you observed.
> 
> Could be that some other code is stomping on per-cpu variables?

I don't know what was the cause, but mmotm 2008-12-02-17-08 is working fine.

Thanks.
