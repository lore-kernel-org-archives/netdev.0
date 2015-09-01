From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Tue, 01 Sep 2015 00:00:51 -0700 (PDT)
Message-ID: <20150901.000051.2053259950492309439.davem@davemloft.net>
References: <20140825.163502.973913220915588977.davem@davemloft.net>
	<55E549CE.4010509@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: Yanjun.Zhu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbbIAHAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 03:00:55 -0400
In-Reply-To: <55E549CE.4010509@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yzhu1 <Yanjun.Zhu@windriver.com>
Date: Tue, 1 Sep 2015 14:46:38 +0800

> After I applied this patch, the skb->xmit_more is not always zero.

There have been thousands upon thousands of commits since that
change.

You should be testing the tree as it currently stands, to see
if xmit_more behaves correctly or not.

If xmit_more were incorrectly set to 1 in the current tree, it
would stall the TX queue of the networking device and we would
be seeing lots of reports of this.
