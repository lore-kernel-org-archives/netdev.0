From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Wed, 06 Aug 2008 12:21:06 +0800
Message-ID: <489926B2.7030800@cn.fujitsu.com>
References: <4892E6EC.3040201@cn.fujitsu.com> <4898238F.1050105@cn.fujitsu.com> <20080805.030433.100665376.davem@davemloft.net> <200808051051.49824.divy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61064 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751988AbYHFEX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 00:23:26 -0400
In-Reply-To: <200808051051.49824.divy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray said the following on 2008-8-6 1:51:
> On Tuesday 05 August 2008 03:04:33 am David Miller wrote:
>> From: Wang Chen <wangchen@cn.fujitsu.com>
>> Date: Tue, 05 Aug 2008 17:55:27 +0800
>>
>>> init_one() of cxgb2 makes several net_device to share one private data.
>>> For this purpose, direct reference is necessary.
>> It should use netdev->ml_priv which is created for this purpose.
>>
>> Every direct netdev->priv usage is a bug.
> 
> cxgb3 was fixed in this regard, cxgb2 needs the same treatment ...
> 

Thanks Dave and Divy.
I am making the big patch for fixing all direct reference of netdev->priv.

