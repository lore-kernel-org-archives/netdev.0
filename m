From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: vhost_dev_cleanup() crash: BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 2 Sep 2010 00:42:21 +0300
Message-ID: <20100901214221.GA15182@redhat.com>
References: <1283251801.2550.53.camel@edumazet-laptop>
 <20100831111413.GB12853@elte.hu>
 <1283256357.2550.61.camel@edumazet-laptop>
 <20100901.142528.180418526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, mingo@elte.hu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100901.142528.180418526.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2010 at 02:25:28PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 31 Aug 2010 14:05:57 +0200
> 
> > [PATCH v2] vhost: stop worker only if created
> > 
> > Its currently illegal to call kthread_stop(NULL)
> > 
> > Reported-by: Ingo Molnar <mingo@elte.hu>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> I'll apply this thanks Eric.

Yes, it looks good thanks!
Acked-by: Michael S. Tsirkin <mst@redhat.com>

Or you can wait for my pull request (will have a couple other regression
fixes).
