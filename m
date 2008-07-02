From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: WAN: Remove dead code from wanmain.c, CONFIG_WANPIPE_MULTPPP doesn't exist
Date: Wed, 02 Jul 2008 22:21:34 +0200
Message-ID: <m363ro3ult.fsf@maximus.localdomain>
References: <m3r6ac3xs8.fsf@maximus.localdomain>
	<20080702201754.GA2145@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:56878 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbYGBUVg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 16:21:36 -0400
In-Reply-To: <20080702201754.GA2145@cs181140183.pp.htv.fi> (Adrian Bunk's message of "Wed\, 2 Jul 2008 23\:17\:55 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk <bunk@kernel.org> writes:

>> -#ifdef CONFIG_WANPIPE_MULTPPP
>> -		pppdev = kzalloc(sizeof(struct ppp_device), GFP_KERNEL);
>> -		err = -ENOBUFS;
>> -		if (pppdev == NULL)
>> -			goto out;
>> -		pppdev->dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
>> -		if (pppdev->dev == NULL) {
>> -			kfree(pppdev);
>> -			err = -ENOBUFS;
>> -			goto out;
>> -		}
>> -		err = wandev->new_if(wandev, (struct net_device *)pppdev, cnf);
>> -		dev = pppdev->dev;
>> -#else
>>  		printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
>>  				wandev->name);
>
> The printk() also needs some updating.

Agreed.
-- 
Krzysztof Halasa
