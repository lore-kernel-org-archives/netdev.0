From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next]netdevice: 82596: Convert netdev->priv to netdev_priv
Date: Mon, 17 Nov 2008 14:58:35 +0800
Message-ID: <4921161B.90605@cn.fujitsu.com>
References: <4921095D.9010109@cn.fujitsu.com> <20081116.223637.108010315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52507 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbYKQG66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 01:58:58 -0500
In-Reply-To: <20081116.223637.108010315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-11-17 14:36:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Mon, 17 Nov 2008 14:04:13 +0800
> 
>> -#ifdef __mc68000__
>> -	cache_push(virt_to_phys((void *)(dev->mem_start)), 4096);
>> -	cache_clear(virt_to_phys((void *)(dev->mem_start)), 4096);
>> -	kernel_set_cachemode((void *)(dev->mem_start), 4096, IOMAP_NOCACHE_SER);
>> -#endif
> 
> Do you have any idea what this code is doing that you are removing?
> 
> It's changing the cache mode of the memory behind ->mem_start because
> this "lp" struct is directly accessed by the hardware, and without
> these operations the CPU and the device won't see consistent
> values in the structure.
> 
> Therefore your change breaks the driver.
> 

Yes. I was wrong.
Will send a patch again.
Thank you for stopping my fool code.

