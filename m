From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/1] net: fec: fix build error at m68k platform
Date: Tue, 16 Sep 2014 16:50:46 -0400 (EDT)
Message-ID: <20140916.165046.729135736826887555.davem@davemloft.net>
References: <1410892458-2113-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbaIPUus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:50:48 -0400
In-Reply-To: <1410892458-2113-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Frank.Li@freescale.com>
Date: Wed, 17 Sep 2014 02:34:18 +0800

> From: Frank Li <Frank.Li@freescale.com>
> 
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 4d494cdc92b3b9a0f5fb9e1560810fa27d5a0489
>   make.cross ARCH=m68k  m5272c3_defconfig
>   make.cross ARCH=m68k
> 
> drivers/net/ethernet/freescale/fec.h:262:0: warning: "FEC_R_DES_START" redefined
>  #define FEC_R_DES_START(X) ((X == 1) ? FEC_R_DES_START_1 : \
>  ^
> drivers/net/ethernet/freescale/fec.h:158:0: note: this is the location of the previous definition
>  #define FEC_R_DES_START  0x3d0 /* Receive descriptor ring */
>  ^
> drivers/net/ethernet/freescale/fec.h:265:0: warning: "FEC_X_DES_START" redefined
>  #define FEC_X_DES_START(X) ((X == 1) ? FEC_X_DES_START_1 : \
> 
> ...
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied.
