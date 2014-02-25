From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/2] bonding: Fix RTNL: assertion failed at
 net/core/rtnetlink.c for 802.3ad mode
Date: Tue, 25 Feb 2014 17:32:44 -0500 (EST)
Message-ID: <20140225.173244.1761467022630063500.davem@davemloft.net>
References: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
	<1392800711-19264-2-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	cwang@twopensource.com, jiri@resnulli.us, thomas@glanzmann.de,
	eric.dumazet@gmail.com, sfeldma@cumulusnetworks.com,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaBYWcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 17:32:47 -0500
In-Reply-To: <1392800711-19264-2-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 19 Feb 2014 17:05:10 +0800

> @@ -2062,6 +2062,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>  	struct list_head *iter;
>  	struct slave *slave;
>  	struct port *port;
> +	int slave_should_notify = 0;

Please use bool, true/false, for slave_should_notify.

Thanks.
