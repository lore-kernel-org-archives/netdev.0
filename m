From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next:master 1118/1134]
 drivers/net/dsa/b53/b53_srab.c:388:20: warning: cast from pointer to integer
 of different size
Date: Mon, 11 Jul 2016 14:37:32 -0700
Message-ID: <5784119C.7070308@gmail.com>
References: <201607120549.q93JxhcC%fengguang.wu@intel.com>
 <20160711.143125.685534519604579905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33885 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbcGKVhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:37:35 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so3786111pac.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 14:37:35 -0700 (PDT)
In-Reply-To: <20160711.143125.685534519604579905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2016 02:31 PM, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Tue, 12 Jul 2016 05:19:57 +0800
> 
>> All warnings (new ones prefixed by >>):
>>
>>    drivers/net/dsa/b53/b53_srab.c: In function 'b53_srab_probe':
>>>> drivers/net/dsa/b53/b53_srab.c:388:20: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
>>       pdata->chip_id = (u32)of_id->data;
>>                        ^
>>
> 
> Fixed as follows:
> 
> ====================
> [PATCH] b53: Fix build warning.
> 
>    drivers/net/dsa/b53/b53_srab.c: In function 'b53_srab_probe':
>>> drivers/net/dsa/b53/b53_srab.c:388:20: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
>       pdata->chip_id = (u32)of_id->data;
>                        ^
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

You are fast, thanks David!
-- 
Florian
