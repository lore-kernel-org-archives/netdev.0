From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Tue, 05 Aug 2008 17:55:27 +0800
Message-ID: <4898238F.1050105@cn.fujitsu.com>
References: <4892E280.8050907@cn.fujitsu.com>	<20080801.032424.114777556.davem@davemloft.net>	<4892E6EC.3040201@cn.fujitsu.com> <20080801.040518.93393560.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52847 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756748AbYHEJ5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 05:57:45 -0400
In-Reply-To: <20080801.040518.93393560.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-8-1 19:05:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 01 Aug 2008 18:35:24 +0800
> 
>> How about add a comment to netdev->priv
>>
>> void	*priv;	/* pointer to private data, referent me by netdev_priv()*/
> 
> Sure, but I'd much rather apply a patch that converts
> all the direct references :-)

I just checked some drivers' source.
And, maybe some direct references of net_device->priv are needed.
For example:
init_one() of cxgb2 makes several net_device to share one private data.
For this purpose, direct reference is necessary.

