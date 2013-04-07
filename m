From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 3/3] net/mlx4_en: Advertize
 DCB_CAP_DCBX_HOST in getdcbx
Date: Sun, 07 Apr 2013 16:56:16 -0400 (EDT)
Message-ID: <20130407.165616.753979562225423725.davem@davemloft.net>
References: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
	<1365342248-31901-4-git-send-email-ogerlitz@mellanox.com>
	<5161914F.8020801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org, amirv@mellanox.com,
	sagig@mellanox.com, john.r.fastabend@intel.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934334Ab3DGU4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 16:56:17 -0400
In-Reply-To: <5161914F.8020801@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 07 Apr 2013 19:31:27 +0400

>> @@ -186,7 +186,7 @@ static int mlx4_en_dcbnl_ieee_setpfc(struct
>> net_device *dev,
>>
>>   static u8 mlx4_en_dcbnl_getdcbx(struct net_device *dev)
>>   {
>> -	return DCB_CAP_DCBX_VER_IEEE;
>> +	return (DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE);
> 
>    Nit: parens not needed here.

I made this simplification when I applied this patch, thanks.
