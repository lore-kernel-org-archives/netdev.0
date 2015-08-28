From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc
 to inappropriate ones
Date: Fri, 28 Aug 2015 16:20:37 -0700 (PDT)
Message-ID: <20150828.162037.473306692661391284.davem@davemloft.net>
References: <CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
	<20150827.212359.1624170801280596846.davem@davemloft.net>
	<CAM_iQpVqgFMoKE8JGpHw3e+YTqRoVYADoKBprFaaV-Es=uDKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbbH1XUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 19:20:40 -0400
In-Reply-To: <CAM_iQpVqgFMoKE8JGpHw3e+YTqRoVYADoKBprFaaV-Es=uDKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 28 Aug 2015 14:39:45 -0700

> If HTB is not a good example, as using HTB as default might
> make some sense, please try ingress qdisc, no error at _any_ time,
> and apparently defaulting to ingress is totally non-sense.

I agree that ingress should have some special flag that prevents
it from being an egress qdisc.

But HTB definitely should be allowed.
