From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac802154: fix following checkpath.pl warning Prefer
 pr_warn(... to pr_warning(...
Date: Sun, 22 Dec 2013 18:05:40 -0500 (EST)
Message-ID: <20131222.180540.1526177824570276905.davem@davemloft.net>
References: <1387359364-5892-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab3LVXFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:05:42 -0500
In-Reply-To: <1387359364-5892-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Weilong <chenweilong@huawei.com>
Date: Wed, 18 Dec 2013 17:36:04 +0800

> -		pr_warning("ieee802154: bad frame received (type = %d)\n",
> +		pr_warn("ieee802154: bad frame received (type = %d)\n",
>  			   mac_cb_type(skb));

You have to fix up the indentation of the second line if you adjust the
first line like this.
