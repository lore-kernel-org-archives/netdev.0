From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched actions: bug fix dumping actions
 directly didnt produce NLMSG_DONE
Date: Wed, 15 Jun 2016 14:03:04 -0700 (PDT)
Message-ID: <20160615.140304.366893182696453314.davem@davemloft.net>
References: <1465855722-26727-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbcFOVDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:03:06 -0400
In-Reply-To: <1465855722-26727-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 13 Jun 2016 18:08:42 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> This refers to commands to direct action access as follows:
> 
> sudo tc actions add action drop index 12
> sudo tc actions add action pipe index 10
> 
> And then dumping them like so:
> sudo tc actions ls action gact
> 
> iproute2 worked because it depended on absence of TCA_ACT_TAB TLV
> as end of message.
> This fix has been tested with iproute2 and is backward compatible.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
