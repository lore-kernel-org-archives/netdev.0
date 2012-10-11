From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next? V2] pktgen: Use simpler test for non-zero ipv6 address
Date: Thu, 11 Oct 2012 10:15:51 +0800
Message-ID: <CAM_iQpWn8XHZ8VwRGFPjcAvPRAPy82eFT=5tqVzWHq5iXff_wA@mail.gmail.com>
References: <1349894559.2035.12.camel@joe-AO722>
	<1349895710.21172.7235.camel@edumazet-glaptop>
	<1349897005.2035.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brian Haley <brian.haley@hp.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349897005.2035.24.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2012 at 3:23 AM, Joe Perches <joe@perches.com> wrote:
> Reduces object size and should be slightly faster.
>
> allyesconfig:
> $ size net/core/pktgen.o*
>    text    data     bss     dec     hex filename
>   52284    4321   11840   68445   10b5d net/core/pktgen.o.new
>   52310    4293   11848   68451   10b63 net/core/pktgen.o.old
>
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good.

This should go to -net, net-next is not open currently.

Thanks.
