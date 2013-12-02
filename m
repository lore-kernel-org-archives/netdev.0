From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: judge the accept_ra_defrtr before calling
 rt6_route_rcv
Date: Mon, 02 Dec 2013 16:01:07 -0500 (EST)
Message-ID: <20131202.160107.287731047825113467.davem@davemloft.net>
References: <529451F0.1060707@cn.fujitsu.com>
	<20131129060945.GJ24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758907Ab3LBVBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 16:01:11 -0500
In-Reply-To: <20131129060945.GJ24171@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 29 Nov 2013 07:09:45 +0100

> On Tue, Nov 26, 2013 at 03:46:56PM +0800, Duan Jiong wrote:
>> 
>> when dealing with a RA message, if accept_ra_defrtr is false,
>> the kernel will not add the default route, and then deal with
>> the following route information options. Unfortunately, those
>> options maybe contain default route, so let's judge the
>> accept_ra_defrtr before calling rt6_route_rcv.
>> 
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> I am ambivalent regarding this change.
> 
> accept_ra_defrtr protected against adding default routers without routing
> options and accept_ra_rt_info_max_plen == -1 disables the acceptance of any
> routing options in router advertisments.
> 
> I don't have an idea why we need this distinction altough I once used it for
> testing. But because this change makes it more understandable for users I am
> ok with that.

I've applied this, thanks everyone.
