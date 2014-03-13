From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Don't receive packets when the napi
 budget == 0
Date: Thu, 13 Mar 2014 15:19:14 -0400 (EDT)
Message-ID: <20140313.151914.1157127125350980588.davem@davemloft.net>
References: <87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbaCMTTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:19:17 -0400
In-Reply-To: <877g808luk.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Mar 2014 14:30:11 -0700

> To the best of understanding processing any received packets when the
> napi budget == 0 is broken driver behavior.  At the same time I don't
> think we have ever cared before so there are a handful of drivers that
> need fixes.
> 
> I care now as I will shortly be using htis in netpoll to get the
> tx queue processing without the rx queue processing.
> 
> Drivers that need fixes are few and far between, and so far I have only
> found two of them.  More similar patches later if I find more drivers
> that need fixes.

Series applied, thanks Eric.
