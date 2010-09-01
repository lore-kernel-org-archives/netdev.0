From: David Miller <davem@davemloft.net>
Subject: Re: vhost_dev_cleanup() crash: BUG: unable to handle kernel NULL
 pointer dereference
Date: Wed, 01 Sep 2010 14:25:28 -0700 (PDT)
Message-ID: <20100901.142528.180418526.davem@davemloft.net>
References: <1283251801.2550.53.camel@edumazet-laptop>
	<20100831111413.GB12853@elte.hu>
	<1283256357.2550.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, tj@kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283256357.2550.61.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Aug 2010 14:05:57 +0200

> [PATCH v2] vhost: stop worker only if created
> 
> Its currently illegal to call kthread_stop(NULL)
> 
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this thanks Eric.
