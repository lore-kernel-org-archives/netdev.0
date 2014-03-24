From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] net: tcp_ipv6 policy route issue
Date: Mon, 24 Mar 2014 00:13:55 -0400 (EDT)
Message-ID: <20140324.001355.2184736984324713082.davem@davemloft.net>
References: <1395624961-10128-1-git-send-email-wangyufen@huawei.com>
	<1395624961-10128-2-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaCXEN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 00:13:59 -0400
In-Reply-To: <1395624961-10128-2-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wangyufen <wangyufen@huawei.com>
Date: Mon, 24 Mar 2014 09:36:01 +0800

> From: Wang Yufen <wangyufen@huawei.com>
> 
> The issue raises when adding policy route,specify a particular
> NIC as oif. The policy route did not take effect.The reason is
> that fl6.oif is not set and route map failed. From the 
> tcp_v6_send_response function,if the binding address is linklocal,
> fl6.oif is set,but not for global address.
> 
> Signed-off-by: Wang Yufen <wangyufen@huawei.com>

You didn't follow all of my feedback.  I said that there must
be a space after punctuation characters, such as "," in your
commit message.

You lack a space after all such characters.
