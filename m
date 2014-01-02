From: chenweilong <chenweilong@huawei.com>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable
 lo
Date: Thu, 2 Jan 2014 17:08:15 +0800
Message-ID: <52C52C7F.6080108@huawei.com>
References: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com> <20130619.230532.1329281330568271336.davem@davemloft.net> <20131231035718.GB27636@order.stressinduktion.org> <52C4FDBE.5030607@huawei.com> <20140102060318.GA22494@order.stressinduktion.org> <52C51FB4.3000008@huawei.com> <20140102083200.GD22494@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:55698 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaABJJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 04:09:33 -0500
In-Reply-To: <20140102083200.GD22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/2 16:32, Hannes Frederic Sowa wrote:
> On Thu, Jan 02, 2014 at 04:13:40PM +0800, chenweilong wrote:
>> Can you give more explanation about this please?
> 
> If you look at the routing table for local addresses (ip -6 route list table
> local), you see that every address which is RTF_LOCAL (and thus passes up the
> packets via ip6_input) has as its device the loopback device.
> 
> In case you shutdown loopback you clear all those routes, thus incoming
> packets won't find the corresponding rt6_info which directs the packets to
> passed up the stack.
> 
> I guess it was done to satisfy the scoped architecture of IPv6.
> 
> Does this help you?
> 
> 
> 
Yes,thanks very much!
