From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] netpoll: Use skb_irq_freeable to make
 zap_completion_queue safe.
Date: Tue, 01 Apr 2014 17:54:12 -0400 (EDT)
Message-ID: <20140401.175412.1103908241120101573.davem@davemloft.net>
References: <8761mzktj9.fsf_-_@x220.int.ebiederm.org>
	<53357681.9050200@cogentembedded.com>
	<87wqf8j1rx.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, eric.dumazet@gmail.com, ben@decadent.org.uk,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	David.Laight@ACULAB.COM, sergei.shtylyov@cogentembedded.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbaDAVyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:54:14 -0400
In-Reply-To: <87wqf8j1rx.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 01 Apr 2014 12:19:30 -0700

> Resending with the requested typo fix in the commit message and
> pruned down to just the bare minimal bug fix, that this patchset is.

Series applied, I added the "const" to the skb_irq_freeable() argument
as suggested by Eric Dumazet.
