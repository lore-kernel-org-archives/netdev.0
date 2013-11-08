From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net_sched: fix some checkpatch errors
Date: Thu, 07 Nov 2013 19:19:45 -0500 (EST)
Message-ID: <20131107.191945.629524953531140070.davem@davemloft.net>
References: <1383817918-5156-1-git-send-email-yangyingliang@huawei.com>
	<1383817918-5156-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	stephen@networkplumber.org, dborkman@redhat.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997Ab3KHATr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:19:47 -0500
In-Reply-To: <1383817918-5156-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Thu, 7 Nov 2013 17:51:57 +0800

> -			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
> +			if (cl->quantum <= 0 ||
> +				cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {

Still not indented properly.

The first character on the second line _MUST_ line up with the first column
after the openning parenthesis of the if() statement.  If you are just
using TAB characters to ident, you are doing it wrong.  You must use
the correct number of TAB and SPACE characters to reach the goal
column.
