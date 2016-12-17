From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvpp2: fix dma unmapping of TX buffers for
 fragments
Date: Sat, 17 Dec 2016 11:35:48 -0500 (EST)
Message-ID: <20161217.113548.422416317077715115.davem@davemloft.net>
References: <1481647995-7213-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <20161217.102057.1497114610120684110.davem@davemloft.net>
        <20161217162658.63bc2423@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        stefanc@marvell.com, nadavh@marvell.com, hannah@marvell.com,
        yehuday@marvell.com, raphael.glon@corp.ovh.com,
        stable@vger.kernel.org
To: thomas.petazzoni@free-electrons.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20161217162658.63bc2423@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sat, 17 Dec 2016 16:26:58 +0100

> Yes, I was thinking of moving towards a single array, as it's indeed
> crazy to have three arrays for that. However, since it's a fix going
> into stable, I also wanted to keep it as simple/straightforward as
> possible and avoid refactoring other parts of the code.

By the same token, by adding a third array you are making the code
more complex, adding more error recovery paths, etc.

> If you however believe moving to one array should be done as part of
> the fix, I'll do this.

Please do.
