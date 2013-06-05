From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: move mac_pton() to lib/net_utils.c
Date: Tue, 04 Jun 2013 17:43:23 -0700 (PDT)
Message-ID: <20130604.174323.350497684225826523.davem@davemloft.net>
References: <1370364386-5034-1-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370364386-5034-1-git-send-email-andy.shevchenko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Tue,  4 Jun 2013 19:46:26 +0300

> Since we have at least one user of this function outside of CONFIG_NET
> scope, we have to provide this function independently. The proposed
> solution is to move it under lib/net_utils.c with corresponding
> configuration variable and select wherever it is needed.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
> Reported-by: Arnd Bergmann <arnd@arndb.de>

I do not see a mac_pton() usage under drivers/misc in any of my trees,
so I really am not the person to apply this.
