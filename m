From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lantiq_etop: Remove unused 'i' variable
Date: Sun, 04 Sep 2016 11:48:10 -0700 (PDT)
Message-ID: <20160904.114810.1786923584461227168.davem@davemloft.net>
References: <20160902142654.4195-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andrew@lunn.ch, fw@strlen.de, f.fainelli@gmail.com
To: paul.burton@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902142654.4195-1-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Burton <paul.burton@imgtec.com>
Date: Fri, 2 Sep 2016 15:26:54 +0100

> Commit e7f4dc3536a4 ("mdio: Move allocation of interrupts into core")
> removed the only use of the 'i' variable from ltq_etop_mdio_init() but
> left the variable declaration behind, leading to the following compiler
> warning:
> 
>   drivers/net/ethernet/lantiq_etop.c: In function 'ltq_etop_mdio_init':
>   drivers/net/ethernet/lantiq_etop.c:414:6: warning: unused variable 'i' [-Wunused-variable]
>     int i;
>         ^
> 
> Fix this by removing the declaration of the 'i' variable.
> 
> Signed-off-by: Paul Burton <paul.burton@imgtec.com>

This appears to already be fixed in net-next
