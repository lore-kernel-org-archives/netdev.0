From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 2/2] atm: he: print MAC via %pM
Date: Tue, 03 Sep 2013 05:20:06 -0700
Message-ID: <1378210806.2048.23.camel@joe-AO722>
References: <1378210424-14781-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1378210424-14781-2-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net,
	inux Net Dev <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58682 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752764Ab3ICMUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 08:20:08 -0400
In-Reply-To: <1378210424-14781-2-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 15:13 +0300, Andy Shevchenko wrote:
[]
> diff --git a/drivers/atm/he.c b/drivers/atm/he.c
[]
> @@ -1088,15 +1088,8 @@ static int he_start(struct atm_dev *dev)
>  	for (i = 0; i < 6; ++i)
>  		dev->esi[i] = read_prom_byte(he_dev, MAC_ADDR + i);
>  
> -	hprintk("%s%s, %x:%x:%x:%x:%x:%x\n",
> -				he_dev->prod_id,
> -					he_dev->media & 0x40 ? "SM" : "MM",
> -						dev->esi[0],
> -						dev->esi[1],
> -						dev->esi[2],
> -						dev->esi[3],
> -						dev->esi[4],
> -						dev->esi[5]);
> +	hprintk("%s%s, %*pM\n", he_dev->prod_id,
> +		he_dev->media & 0x40 ? "SM" : "MM", dev->esi);

%*pM?

Did this compile cleanly?
