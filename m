From: Nicolas Kaiser <nikai@nikai.net>
Subject: Re: [patch] isdn: return -EFAULT if copy_from_user() fails
Date: Sat, 11 Dec 2010 01:41:54 +0100
Message-ID: <20101211014154.3157588b@absol.kitzblitz>
References: <20101210124009.GC10623@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:43437 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757321Ab0LKAnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:43:24 -0500
In-Reply-To: <20101210124009.GC10623@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ahem, we're printing this return value:

* Dan Carpenter <error27@gmail.com>:
> -	if ((ret = copy_from_user(&size, p, sizeof(int)))) {
             ^^^
> +	if (copy_from_user(&size, p, sizeof(int))) {
>  		printk(KERN_ERR"isar_load_firmware copy_from_user ret %d\n", ret);
                                                                             ^^^
> -		return ret;
> +		return -EFAULT;

Cheers,
Nicolas Kaiser
