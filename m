From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] seeq: fix compile breakage on s390
Date: Thu, 22 Sep 2011 03:50:04 -0400 (EDT)
Message-ID: <20110922.035004.2153309506139942676.davem@davemloft.net>
References: <1316677326-6081-1-git-send-email-heiko.carstens@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: heiko.carstens@de.ibm.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1316677326-6081-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Thu, 22 Sep 2011 09:42:06 +0200

> The SEEQ drivers should depend on HAS_IOMEM to prevent compile breakage
> on !HAS_IOMEM architectures:
> 
> drivers/net/ethernet/seeq/seeq8005.c: In function 'seeq8005_probe1':
> drivers/net/ethernet/seeq/seeq8005.c:179:2: error:
>   implicit declaration of function 'inw' [-Werror=implicit-function-declaration]
> 
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Applied, thanks.
