From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] net: mvpp2: fix the dma_mask and
 coherent_dma_mask settings for PPv2.2
Date: Thu, 21 Sep 2017 10:07:18 -0700 (PDT)
Message-ID: <20170921.100718.386894052177530033.davem@davemloft.net>
References: <20170918130408.23114-2-antoine.tenart@free-electrons.com>
        <20170918.171858.667084185425779267.davem@davemloft.net>
        <20170921142413.GH3568@kwain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921142413.GH3568@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Thu, 21 Sep 2017 16:24:13 +0200

> That's also the default when the platform does not allocate dma_mask.

That's the problem that needs to be fixed then.
