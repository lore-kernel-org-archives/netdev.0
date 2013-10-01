From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: moxa: fix incorrect placement of __initdata
 tag
Date: Mon, 30 Sep 2013 22:17:31 -0700 (PDT)
Message-ID: <20130930.221731.1527688326511547313.davem@davemloft.net>
References: <172588984.DhoE4BmVdc@amdc1032>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jonas.jensen@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kyungmin.park@samsung.com
To: b.zolnierkie@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <172588984.DhoE4BmVdc@amdc1032>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Date: Mon, 30 Sep 2013 15:18:27 +0200

> __initdata tag should be placed between the variable name and equal
> sign for the variable to be placed in the intended .init.data section.
> 
> In this particular case __initdata is incorrect as moxart_mac_driver
> can be used after the driver gets initialized.
> 
> Also while at it static-ize moxart_mac_driver.
> 
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Applied, thanks.
