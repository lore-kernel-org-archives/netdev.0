From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4] ipv6: handle Redirect ICMP Message with no
 Redirected Header option
Date: Thu, 22 Aug 2013 20:08:34 -0700 (PDT)
Message-ID: <20130822.200834.2106042613284274785.davem@davemloft.net>
References: <52158E87.7060305@cn.fujitsu.com>
	<20130822114803.GA30722@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab3HWDIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 23:08:35 -0400
In-Reply-To: <20130822114803.GA30722@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 22 Aug 2013 13:48:03 +0200

> On Thu, Aug 22, 2013 at 12:07:35PM +0800, Duan Jiong wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> 
>> rfc 4861 says the Redirected Header option is optional, so
>> the kernel should not drop the Redirect Message that has no
>> Redirected Header option. In this patch, the function
>> ip6_redirect_no_header() is introduced to deal with that
>> condition.
>> 
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
