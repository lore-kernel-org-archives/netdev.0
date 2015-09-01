From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Remove ndo_xmit_flush netdev operation, use
 signalling instead.
Date: Tue, 01 Sep 2015 00:13:50 -0700 (PDT)
Message-ID: <20150901.001350.941689235465955275.davem@davemloft.net>
References: <55E549CE.4010509@windriver.com>
	<20150901.000051.2053259950492309439.davem@davemloft.net>
	<55E54F5F.9040603@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: Yanjun.Zhu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbbIAHNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 03:13:51 -0400
In-Reply-To: <55E54F5F.9040603@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yzhu1 <Yanjun.Zhu@windriver.com>
Date: Tue, 1 Sep 2015 15:10:23 +0800

> After running for several days, the following messages will
> appear.

Then you need to figure out why the value is being set.

It is initialized to zero by every SKB allocation, and only
very specific controlled code paths set it non-zero.

Memory corruption is a very real possibility.
