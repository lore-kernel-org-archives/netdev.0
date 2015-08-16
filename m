From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rhashtable-test: extend to test concurrency
Date: Sun, 16 Aug 2015 17:02:44 +0200
Message-ID: <20150816150244.GA6844@pox.localdomain>
References: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/15 at 12:37am, Phil Sutter wrote:
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

Looks great. A default of 10 makes sense as well. Thanks a lot!

Acked-by: Thomas Graf <tgraf@suug.ch>
