From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH] bonding: set correct tx_queue_len for bond_dev
Date: Tue, 30 Jul 2013 17:24:54 +0800
Message-ID: <51F78666.3050801@huawei.com>
References: <51F7694A.1060703@huawei.com> <20130730.003403.299786235452826263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <fubar@us.ibm.com>, <andy@greyhouse.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:58561 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680Ab3G3JZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 05:25:11 -0400
In-Reply-To: <20130730.003403.299786235452826263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/30 15:34, David Miller wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> Date: Tue, 30 Jul 2013 15:20:42 +0800
> 
>> With htb, sch->limit is set from bond_dev->tx_queue_len which
>> is initialized to 0 in bond_setup.
> 
> This is intentional, software devices should not queue TX
> packets.

This makes software devices with htb qdisc can hold only
one packet, others are dropped.

Maybe sch->limit's default value which is 1 is too small. 
Instead of this patch, I'll send another patch to fix this 
value for fixing this issue.
> 
> You can only use the packet scheduler with hardware devices.
> 
> 
