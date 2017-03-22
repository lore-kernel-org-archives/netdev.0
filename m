From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [net-next] net: dwc-xlgmac: include dcbnl.h
Date: Wed, 22 Mar 2017 10:53:10 -0700 (PDT)
Message-ID: <20170322.105310.2144033011962142655.davem@davemloft.net>
References: <20170320085123.1032301-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiedeng@synopsys.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320085123.1032301-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 20 Mar 2017 09:51:12 +0100

> Without this header, we can run into a build error:
> 
> drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c: In function 'xlgmac_config_queue_mapping':
> drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c:1548:36: error: 'IEEE_8021QAZ_MAX_TCS' undeclared (first use in this function)
>   prio_queues = min_t(unsigned int, IEEE_8021QAZ_MAX_TCS,
> 
> Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
