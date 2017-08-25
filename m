From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: mvpp2: fix the mac address retrieval
 logic
Date: Thu, 24 Aug 2017 21:46:24 -0700 (PDT)
Message-ID: <20170824.214624.250495333472785242.davem@davemloft.net>
References: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824094658.1296-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Thu, 24 Aug 2017 11:46:54 +0200

> The MAC address retrieval logic was broken and when using the PPv2
> driver on PPv2.2 engines I ended up using the same mac address on all
> ports. This series of patches fixes this, and also tackle a possible bug
> when defining the mac address in the device tree.
> 
> To fix this in a nice way I ended up using a dedicated function to
> handle the mac retrieval logic. This can be hard to backport into stable
> kernels. This is why I also made a quick fix which is easy to backport
> (patch 1/14), to tackle down the PPv2.2 mac retrieval bug. Let me know
> if this approach is the proper way to handle this or if I should do
> something else.

This patch series doesn't apply to any of my trees, that is the first
thing.

Secondly, this is a bug fix, and the bug exists in the 'net' tree.
Therefore this patch series should target the 'net' tree.

Please always target legitimate bug fixes at the 'net' tree, rather
than 'net-next'.

Thank you.
