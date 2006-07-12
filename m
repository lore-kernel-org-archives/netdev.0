From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx-d80211: use SET_NETDEV_DEV
Date: Wed, 12 Jul 2006 22:31:48 +0200
Message-ID: <200607122231.49097.mb@bu3sch.de>
References: <20060712190120.7c909ac7@griffin.suse.cz> <20060712190246.0427ff70@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Dan Williams <dcbw@redhat.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27821
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751157AbWGLU3x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:29:53 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060712190246.0427ff70@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 July 2006 19:02, you wrote:
> This adds /sys/class/net/wmaster0/device symlink.
> 
> Signed-off-by: Jiri Benc <jbenc@suse.cz>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> 
> ---
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    1 +
>  1 files changed, 1 insertion(+)
> 
> --- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -4722,6 +4722,7 @@ static int __devinit bcm43xx_init_one(st
>  		goto err_free_netdev;
>  
>  	pci_set_drvdata(pdev, net_dev);
> +	SET_NETDEV_DEV(net_dev, &pdev->dev);
>  
>  	err = bcm43xx_attach_board(bcm);
>  	if (err)
> 
> 

-- 
Greetings Michael.
