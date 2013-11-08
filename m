From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next v3 1/2] net_sched: fix some checkpatch errors
Date: Fri, 8 Nov 2013 09:53:28 +0800
Message-ID: <527C4418.8010207@huawei.com>
References: <1383817918-5156-1-git-send-email-yangyingliang@huawei.com>	<1383817918-5156-2-git-send-email-yangyingliang@huawei.com> <20131107.191945.629524953531140070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45985 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab3KHBxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 20:53:44 -0500
In-Reply-To: <20131107.191945.629524953531140070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/8 8:19, David Miller wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> Date: Thu, 7 Nov 2013 17:51:57 +0800
> 
>> -			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
>> +			if (cl->quantum <= 0 ||
>> +				cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {
> 
> Still not indented properly.
> 
> The first character on the second line _MUST_ line up with the first column
> after the openning parenthesis of the if() statement.  If you are just
> using TAB characters to ident, you are doing it wrong.  You must use
> the correct number of TAB and SPACE characters to reach the goal
> column.

Ok, i will fix it in v4.
Thanks

> 
> 
