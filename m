From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: act: remove headers in
 include/net/tc_act/
Date: Tue, 14 Jan 2014 18:12:13 -0800 (PST)
Message-ID: <20140114.181213.695613248997119103.davem@davemloft.net>
References: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaAOCMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:12:14 -0500
In-Reply-To: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 14 Jan 2014 17:01:39 -0800

> These headers are not necessary because those definitions in them
> are action specific and are not shared for others. Just move them
> into the C files.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Like Eric, I think this is a dubious change.

There is nothing wrong with using these headers to define the
core data structures used by each of these actions modules.

I'm not applying this, sorry.
