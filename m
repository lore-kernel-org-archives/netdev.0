From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: assign affinity hint to interrupts
Date: Fri, 30 Oct 2015 18:21:38 +0900 (KST)
Message-ID: <20151030.182138.949964414988071678.davem@davemloft.net>
References: <1445968722-29523-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758910AbbJ3JVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 05:21:40 -0400
In-Reply-To: <1445968722-29523-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue, 27 Oct 2015 23:28:42 +0530

> Introduce enic module global variable enic_numa_count[] to store the
> number of affinity_hints set. If there are more than one enic interfaces,
> we do not want them to share same affinity hint cpus. We store the
> history of affinity hint assignment of all interfaces in global variable
> enic_numa_count. Introduce enic_affinity_hint spinlock to access
> enic_numa_count.

This is policy outside of the domain of your driver, no other networking
driver does this.  Please remove this aspect of your change.
