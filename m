From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] atm: dereference of he_dev->rbps_virt in
 he_init_group()
Date: Sat, 19 Sep 2009 11:27:27 -0700
Message-ID: <1253384847.2638.4.camel@Joe-Laptop.home>
References: <20090902.232548.238393942.davem@davemloft.net>
	 <4AA25B06.2090703@gmail.com>
	 <20090911.123725.223971259.davem@davemloft.net>
	 <20090911.125135.148893888.davem@davemloft.net>
	 <4AB51FE7.7030509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1045 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbZISS1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Sep 2009 14:27:25 -0400
In-Reply-To: <4AB51FE7.7030509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-09-19 at 20:16 +0200, Roel Kluin wrote:
> +	int i, ret;
> +		ret = -ENOMEM;
> +		ret = -ENOMEM;
> +			ret = -ENOMEM;
> +		ret = -ENOMEM;
> +		ret = -ENOMEM;
> +		ret = -ENOMEM;
> +		ret = -ENOMEM;
> +		ret = -ENOMEM;
> +out_destroy_rbps_pool:
> +	pci_pool_destroy(he_dev->rbps_pool);
> +	return ret;

It looks as if it'd be clearer to not use variable ret and
simply return -ENOMEM after the out_destroy_rbps_pool label.


