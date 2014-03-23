From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: tcp_ipv6 policy route issue
Date: Sun, 23 Mar 2014 00:45:35 -0400 (EDT)
Message-ID: <20140323.004535.1122322865637645199.davem@davemloft.net>
References: <1395546460-8332-1-git-send-email-wangyufen@huawei.com>
	<1395546460-8332-2-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbaCWEpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 00:45:39 -0400
In-Reply-To: <1395546460-8332-2-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wangyufen <wangyufen@huawei.com>
Date: Sun, 23 Mar 2014 11:47:40 +0800

> From: Wang Yufen <wangyufen@huawei.com>
> 
>     The issue raises when adding policy route,specify a particular
>     NIC as oif. The policy route did not take effect.
>     The reason is that fl6.oif is not set and route map failed.
> 
>     From the tcp_v6_send_response function:
>     If the binding address is linklocal, fl6.oif is set,
>     but not for global address.

Please do not indent your commit log message text like this,
make the text start at the first column just like your Signoff
and From: line.

Please place a space after punction such as "," characters.

> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
