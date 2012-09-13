From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] net_sched: gred: fix qave reporting via netlink
Date: Thu, 13 Sep 2012 16:10:39 -0400 (EDT)
Message-ID: <20120913.161039.104251629136106139.davem@davemloft.net>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
	<1347549755-19438-3-git-send-email-david.ward@ll.mit.edu>
	<50521F97.20503@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.ward@ll.mit.edu, netdev@vger.kernel.org, brosler@cisco.com,
	cyril@ti.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab2IMUKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:10:40 -0400
In-Reply-To: <50521F97.20503@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 13 Sep 2012 14:01:59 -0400

> On 12-09-13 11:22 AM, David Ward wrote:
>> q->vars.qavg is a Wlog scaled value, but q->backlog is not. In order
>> to pass q->vars.qavg as the backlog value, we need to un-scale it.
>> Additionally, the qave value returned via netlink should not be Wlog
>> scaled, so we need to un-scale the result of red_calc_qavg().
>>
>> This caused artificially high values for "Average Queue" to be shown
>> by 'tc -s -d qdisc', but did not affect the actual operation of GRED.
>>
>> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> 
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
