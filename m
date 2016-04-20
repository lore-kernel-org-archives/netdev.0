From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 16:08:49 -0400 (EDT)
Message-ID: <20160420.160849.1254968687102415877.davem@davemloft.net>
References: <1461167023-7640-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcDTUIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 16:08:54 -0400
In-Reply-To: <1461167023-7640-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed, 20 Apr 2016 08:43:43 -0700

> This patch adds a new RTM_GETSTATS message to query link stats via netlink
> from the kernel. RTM_NEWLINK also dumps stats today, but RTM_NEWLINK
> returns a lot more than just stats and is expensive in some cases when
> frequent polling for stats from userspace is a common operation.

With nla_align_64bit() now working properly, I've applied this and it works
on sparc64 too.

Thanks!
