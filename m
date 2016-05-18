From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] Revert "phy: add support for a reset-gpio specification"
Date: Wed, 18 May 2016 09:52:22 -0700
Message-ID: <573C9DC6.9010700@gmail.com>
References: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, linux@roeck-us.net,
	netdev@vger.kernel.org
To: Fabio Estevam <fabio.estevam@nxp.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32919 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344AbcERQwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:52:25 -0400
Received: by mail-pa0-f67.google.com with SMTP id gh9so5355917pac.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:52:24 -0700 (PDT)
In-Reply-To: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2016 09:05 AM, Fabio Estevam wrote:
> Commit da47b4572056 ("phy: add support for a reset-gpio specification")
> causes the following xtensa qemu crash according to Guenter Roeck:
> 
> [    9.366256] libphy: ethoc-mdio: probed
> [    9.367389]  (null): could not attach to PHY
> [    9.368555]  (null): failed to probe MDIO bus
> [    9.371540] Unable to handle kernel paging request at virtual address 0000001c
> [    9.371540]  pc = d0320926, ra = 903209d1
> [    9.375358] Oops: sig: 11 [#1]
> 
> This reverts commit da47b4572056487fd7941c26f73b3e8815ff712a.
> 
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
