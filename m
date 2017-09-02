From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: bcm7xxx: make array bcm7xxx_suspend_cfg
 static, reduces object code size
Date: Fri, 01 Sep 2017 18:31:07 -0700 (PDT)
Message-ID: <20170901.183107.1909375784040394690.davem@davemloft.net>
References: <20170831135715.27978-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831135715.27978-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 31 Aug 2017 14:57:15 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate the array bcm7xxx_suspend_cfg A on the stack, instead
> make it static.  Makes the object code smaller by over 300 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>    6351	   8146	      0	  14497	   38a1	drivers/net/phy/bcm7xxx.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>    5986	   8210	      0	  14196	   3774	drivers/net/phy/bcm7xxx.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
