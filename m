From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] ipv6,mcast: always hold idev->lock before
 mca_lock
Date: Mon, 01 Jul 2013 23:39:52 -0700 (PDT)
Message-ID: <20130701.233952.1511019763676664574.davem@davemloft.net>
References: <20130629135321.GA5884@order.stressinduktion.org>
	<1372514981.29178.10.camel@cr0>
	<20130629144052.GB6519@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, dingtianhong@huawei.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167Ab3GBGjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 02:39:53 -0400
In-Reply-To: <20130629144052.GB6519@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 29 Jun 2013 16:40:52 +0200

> On Sat, Jun 29, 2013 at 10:09:41PM +0800, Cong Wang wrote:
>> On Sat, 2013-06-29 at 15:53 +0200, Hannes Frederic Sowa wrote:
>> > 
>> > If we export __ipv6_get_lladdr in a header, shouldn't we also EXPORT_SYMBOL
>> > it? I am not sure but would have done so.
>> 
>> Why? It is used only by IPv6 module itself.
> 
> Yes, you are right. We don't export ipv6_get_lladdr either, so:
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks!
