From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Mon, 11 Jan 2016 00:05:55 -0500 (EST)
Message-ID: <20160111.000555.957168926959879139.davem@davemloft.net>
References: <201601100657.u0A6vk1B025554@mail.home.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, edumazet@google.com,
	hannes@stressinduktion.org, socketpair@gmail.com,
	penguin-kernel@I-love.SAKURA.ne.jp
To: w@1wt.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201601100657.u0A6vk1B025554@mail.home.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Sun, Jan 10 07:54:56 CET 2016

> It is possible for a process to allocate and accumulate far more FDs than
> the process' limit by sending them over a unix socket then closing them
> to keep the process' fd count low.
> 
> This change addresses this problem by keeping track of the number of FDs
> in flight per user and preventing non-privileged processes from having
> more FDs in flight than their configured FD limit.
> 
> Reported-by: socketpair@gmail.com
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Mitigates: CVE-2013-4312 (Linux 2.0+)
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Willy Tarreau <w@1wt.eu>

Applied and queued up for -stable, thanks!
