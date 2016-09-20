From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH net-next 8/8] net: qualcomm: add QCA7000 UART driver
Date: Tue, 20 Sep 2016 18:43:21 +0200 (CEST)
Message-ID: <1892344073.55581.6d72cb63-829e-43a8-a00a-01ddb332993d.open-xchange@email.1und1.de>
References: <1474376544-20515-9-git-send-email-stefan.wahren@i2se.com>
 <201609202253.jYnEZtwg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, Jiri Slaby <jslaby@suse.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201609202253.jYnEZtwg%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> kbuild test robot <lkp@intel.com> hat am 20. September 2016 um 16:44
> geschrieben:
> 
> 
> Hi Stefan,
> 
> [auto build test ERROR on net-next/master]
> 
> url:
>    https://github.com/0day-ci/linux/commits/Stefan-Wahren/net-qualcomm-add-QCA7000-UART-driver/20160920-210908
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/net/ethernet/qualcomm/qca_uart.c: In function
> 'qcauart_netdev_xmit':
> >> drivers/net/ethernet/qualcomm/qca_uart.c:302:5: error: 'struct net_device'
> >> has no member named 'trans_start'; did you mean 'mem_start'?
>      dev->trans_start = jiffies;

This should be replaced by netif_trans_update(dev)

>         ^~
>    drivers/net/ethernet/qualcomm/qca_uart.c: In function
> 'qcauart_netdev_tx_timeout':
>    drivers/net/ethernet/qualcomm/qca_uart.c:314:29: error: 'struct net_device'
> has no member named 'trans_start'; did you mean 'mem_start'?
>           jiffies, jiffies - dev->trans_start);

and this by dev_trans_start(dev) in the next version.

Sorry about that :-(
