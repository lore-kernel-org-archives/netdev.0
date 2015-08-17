From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable-test: extend to test concurrency
Date: Mon, 17 Aug 2015 14:32:52 -0700 (PDT)
Message-ID: <20150817.143252.890116643769336637.davem@davemloft.net>
References: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Sutter <phil@nwl.cc>
Date: Sat, 15 Aug 2015 00:37:15 +0200

> After having tested insertion, lookup, table walk and removal, spawn a
> number of threads running operations on the same rhashtable. Each of
> them will:
> 
> 1) insert it's own set of objects,
> 2) lookup every successfully inserted object and finally
> 3) remove objects in several rounds until all of them have been removed,
>    making sure the remaining ones are still found after each round.
> 
> This should put a good amount of load onto the system and due to
> synchronising thread startup via two semaphores also extensive
> concurrent table access.
> 
> The default number of ten threads returned within half a second on my
> local VM with two cores. Running 200 threads took about four seconds. If
> slow systems suffer too much from this though, the default could be
> lowered or even set to zero so this extended test does not run at all by
> default.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thank you.
