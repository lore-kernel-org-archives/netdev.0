From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qla4xxx: add a missing include
Date: Wed, 27 May 2015 14:21:17 -0400 (EDT)
Message-ID: <20150527.142117.1711665345600870663.davem@davemloft.net>
References: <1432701824.4060.346.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1432701824.4060.346.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 May 2015 21:43:44 -0700

> From: Eric Dumazet <edumzet@google.com>
> 
> vmalloc.h used to be included from include/net/inet_hashtables.h
> but it is no longer the case.
> 
> Fixes: 095dc8e0c368 ("tcp: fix/cleanup inet_ehash_locks_alloc()")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumzet@google.com>
> ---
> Given its broken in David net-next tree, its probably simpler
> that David merges this fix directly ? Thanks !

Yeah it's easiest if I just apply this to net-next, which I've just done,
thanks Eric.
