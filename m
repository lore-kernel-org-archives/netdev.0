From: Patrick McHardy <kaber@trash.net>
Subject: Re: v2: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Wed, 18 Jun 2008 10:44:10 +0200
Message-ID: <4858CADA.6020807@trash.net>
References: <48568125.4090500@cn.fujitsu.com>	<4857B542.6030703@trash.net>	<48586A04.6040800@cn.fujitsu.com> <20080617.215402.169100957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56533 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbYFRIoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 04:44:15 -0400
In-Reply-To: <20080617.215402.169100957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Wed, 18 Jun 2008 09:51:00 +0800
>> Patrick McHardy said the following on 2008-6-17 20:59:
>>> Assuming the caller does proper error handling, that printk is
>>> not true.
>> Yes.
>> But currently, no caller handling this, and I think even if I make
>> some callers to handle this, but there maybe some callers and their
>> callers do not want to handle error condition.
>> So I need a KERN_WARNING here.
>> If some day, all of the caller handle the error properly, we can
>> remove this printk.
>>
>> Here is v3:
>
> Patrick, ACK?

Yes, thanks.




