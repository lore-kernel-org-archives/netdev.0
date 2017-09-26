From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcm63xx_enet: Use setup_timer and mod_timer
Date: Tue, 26 Sep 2017 11:33:40 -0700 (PDT)
Message-ID: <20170926.113340.239908321617902101.davem@davemloft.net>
References: <1506255084-10943-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, bcm-kernel-feedback-list@broadcom.com,
        arnd@arndb.de, yamada.masahiro@socionext.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: himanshujha199640@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506255084-10943-1-git-send-email-himanshujha199640@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himanshu Jha <himanshujha199640@gmail.com>
Date: Sun, 24 Sep 2017 17:41:24 +0530

> Use setup_timer and mod_timer API instead of structure assignments.
> 
> This is done using Coccinelle and semantic patch used
> for this as follows:
> 
> @@
> expression x,y,z,a,b;
> @@
> 
> -init_timer (&x);
> +setup_timer (&x, y, z);
> +mod_timer (&a, b);
> -x.function = y;
> -x.data = z;
> -x.expires = b;
> -add_timer(&a);
> 
> Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>

Applied to net-next, thanks.
