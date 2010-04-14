From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Tue, 13 Apr 2010 19:00:53 -0700 (PDT)
Message-ID: <20100413.190053.222629252.davem@davemloft.net>
References: <20100414114556.97d7583d.sfr@canb.auug.org.au>
	<20100413.184724.112842393.davem@davemloft.net>
	<20100414115244.f97ca080.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ken_kawasaki@spring.nifty.jp,
	jpirko@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100414115244.f97ca080.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 14 Apr 2010 11:52:44 +1000

> Hi Dave,
> 
> On Tue, 13 Apr 2010 18:47:24 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>> Thanks a lot Stephen, I'll merge net-2.6 into net-next-2.6 to
>> fix this up for you.
> 
> Thanks.
> 
> There was another conflict in drivers/net/virtio_net.c (because there is
> a patch in both your tree and Linus' (via net-current)) that git did not
> quite resolve correctly.  The sg_init_table() in add_recvbuf_small() was
> reinserted by the automatic merge ... I removed it in my merge.

Yes I expected that, the cherrypicked fix gets changed by a subsequent
commit in net-next-2.6 that changes where the scatterlist entries are
stored in that driver.

Anyways, thanks for the heads up.
