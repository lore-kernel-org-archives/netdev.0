From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V4] ipv6: handle Redirect ICMP Message with no Redirected Header option
Date: Thu, 22 Aug 2013 13:48:03 +0200
Message-ID: <20130822114803.GA30722@order.stressinduktion.org>
References: <52158E87.7060305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39513 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153Ab3HVLsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 07:48:04 -0400
Content-Disposition: inline
In-Reply-To: <52158E87.7060305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 12:07:35PM +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> rfc 4861 says the Redirected Header option is optional, so
> the kernel should not drop the Redirect Message that has no
> Redirected Header option. In this patch, the function
> ip6_redirect_no_header() is introduced to deal with that
> condition.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Sorry for not catching the EXPORT_SYMBOL_GPL before.

Thanks,

  Hannes
