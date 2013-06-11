From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: add doc for ip_early_demux sysctl
Date: Tue, 11 Jun 2013 02:34:00 -0700 (PDT)
Message-ID: <20130611.023400.1305427475808933449.davem@davemloft.net>
References: <1370495423-13755-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	alexander.h.duyck@intel.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37578 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab3FKJeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:34:01 -0400
In-Reply-To: <1370495423-13755-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu,  6 Jun 2013 13:10:23 +0800

> +	It may add an additional cost to routing that reduces overall
> +	throughput, in such case you should disable it.

I would state this as "additional cost for pure routing workloads" to
emphasize the fact that the potential bad case is when we are not
delivering to a local socket.

The way you have it worded, it makes it sound like route lookups (in
general) will perform more poorly.  This is simply not the case.
