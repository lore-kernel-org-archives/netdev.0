From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] bnx2: Call dev_kfree_skby_any instead of
 dev_kfree_skb.
Date: Tue, 11 Mar 2014 00:43:32 -0400 (EDT)
Message-ID: <20140311.004332.1434735323137341311.davem@davemloft.net>
References: <871ty9qvaf.fsf_-_@xmission.com>
	<87ppltpgme.fsf_-_@xmission.com>
	<1394509677.21721.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435AbaCKEne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 00:43:34 -0400
In-Reply-To: <1394509677.21721.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Mar 2014 20:47:57 -0700

> Anyway, why can this be called from hard irq ?

Eric B. explains this in his 0/11 posting, the culprit is netpoll.

I had a discussion about this with him on this list last week.
