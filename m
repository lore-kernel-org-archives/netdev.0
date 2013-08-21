From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V3] ipv6: handle Redirect ICMP Message with no Redirected Header option
Date: Wed, 21 Aug 2013 13:17:00 +0200
Message-ID: <20130821111700.GE20223@order.stressinduktion.org>
References: <521468C4.5020700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36839 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab3HULRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 07:17:02 -0400
Content-Disposition: inline
In-Reply-To: <521468C4.5020700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 21, 2013 at 03:14:12PM +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> rfc 4861 says the Redirected Header option is optional, so
> the kernel should not drop the Redirect Message that has no
> Redirected Header option. In this patch, the function
> ip6_redirect_no_header() is introduced to deal with that
> condition.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Sorry for being so picky about local socket delivery before. You were right
all along.

I just tested and reviewed this patch and everything is fine:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Just out of curiosity, can you tell because of which devices you did
this patch?

Thanks,

  Hannes
