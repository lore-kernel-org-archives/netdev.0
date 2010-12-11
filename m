From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: return -EFAULT if copy_from_user() fails
Date: Fri, 10 Dec 2010 16:47:21 -0800 (PST)
Message-ID: <20101210.164721.85429801.davem@davemloft.net>
References: <20101210124009.GC10623@bicker>
	<20101211014154.3157588b@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: nikai@nikai.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756609Ab0LKAqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:46:53 -0500
In-Reply-To: <20101211014154.3157588b@absol.kitzblitz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Kaiser <nikai@nikai.net>
Date: Sat, 11 Dec 2010 01:41:54 +0100

> Ahem, we're printing this return value:
> 
> * Dan Carpenter <error27@gmail.com>:
>> -	if ((ret = copy_from_user(&size, p, sizeof(int)))) {
>              ^^^
>> +	if (copy_from_user(&size, p, sizeof(int))) {
>>  		printk(KERN_ERR"isar_load_firmware copy_from_user ret %d\n", ret);
>                                                                              ^^^
>> -		return ret;
>> +		return -EFAULT;

I'll fix this, thanks.
