From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Tue, 20 Jul 2010 20:27:59 -0700 (PDT)
Message-ID: <20100720.202759.00438343.davem@davemloft.net>
References: <20100721120448.31e325fd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100721120448.31e325fd.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 21 Jul 2010 12:04:48 +1000

> Today's linux-next merge of the net tree got a conflict in
> net/bridge/br_device.c between commit
> 573201f36fd9c7c6d5218cdcd9948cee700b277d ("bridge: Partially disable
> netpoll support") from Linus' tree and commit
> 91d2c34a4eed32876ca333b0ca44f3bc56645805 ("bridge: Fix netpoll support")
> from the net tree.
> 
> The net tree commit seems to be a fuller fix, so I used that.

The net-2.6 changes should be undone as net-next-2.6 has the fixes
that allow bridge netpoll to work properly, thus in net-next-2.6 the
net-2.6 commit is completely unnecessary.

I did this when I merged net-2.6 into net-next-2.6 about an hour ago
:-)
