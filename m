From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: mv643xx_eth: use managed devm_kzalloc
Date: Thu, 11 Apr 2013 13:15:25 -0400 (EDT)
Message-ID: <20130411.131525.534345322345457759.davem@davemloft.net>
References: <1365626527-27233-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<20130410.233933.2109788843089649198.davem@davemloft.net>
	<51665DDF.4060205@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	florian@openwrt.org, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab3DKRP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:15:27 -0400
In-Reply-To: <51665DDF.4060205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Thu, 11 Apr 2013 08:53:19 +0200

> On 04/11/2013 05:39 AM, David Miller wrote:
>> From: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
>> Date: Wed, 10 Apr 2013 22:42:07 +0200
>>
>>> This patch moves shared private data kzalloc to managed devm_kzalloc
>>> and
>>> cleans now unneccessary kfree and error handling.
>>>
>>> Signed-off-by: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
>>
>> This doesn't apply cleanly to the net-next tree.
> 
> Yeah. I sent two single patches for mv643xx_eth, while they should
> have been sent together in one patch set. I'll prepare a cover letter
> and resend both in one patch set.

If you don't number the patches or mention the dependency, there is no way
for people to know.
