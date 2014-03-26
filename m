From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 2/2] net: tcp_ipv6 policy route issue
Date: Wed, 26 Mar 2014 08:05:48 +0100
Message-ID: <20140326070548.GF22086@order.stressinduktion.org>
References: <1395642322-9404-1-git-send-email-wangyufen@huawei.com> <1395642322-9404-2-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Wangyufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60143 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaCZHFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 03:05:50 -0400
Content-Disposition: inline
In-Reply-To: <1395642322-9404-2-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 02:25:22PM +0800, Wangyufen wrote:
> From: Wang Yufen <wangyufen@huawei.com>
> 
> The issue raises when adding policy route, specify a particular
> NIC as oif, the policy route did not take effect. The reason is
> that fl6.oif is not set and route map failed. From the 
> tcp_v6_send_response function, if the binding address is linklocal,
> fl6.oif is set, but not for global address.
> 
> Signed-off-by: Wang Yufen <wangyufen@huawei.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

But this looks like a bug to me, so maybe this is something for net
inclusion.

Thanks,

  Hannes
