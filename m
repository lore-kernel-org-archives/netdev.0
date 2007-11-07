From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport softnet_data
Date: Tue, 06 Nov 2007 23:41:13 -0800 (PST)
Message-ID: <20071106.234113.248978883.davem@davemloft.net>
References: <20071024162425.GI30533@stusta.de>
	<20071026.041906.223457165.davem@davemloft.net>
	<BAE9DCEF64577A439B3A37F36F9B691C034CC519@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, christopher.leech@intel.com,
	dan.j.williams@intel.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756167AbXKGHlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 02:41:20 -0500
In-Reply-To: <BAE9DCEF64577A439B3A37F36F9B691C034CC519@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nelson, Shannon" <shannon.nelson@intel.com>
Date: Fri, 26 Oct 2007 08:38:55 -0700

> There is no creation of a pinned_list yet in this path, so I don't think
> this would do us much good.

The pinned list is created in the generic net/ipv4/tcp.c code, not in
the address family specific code.

So your comments do not apply as a reason for this patch to not go in.
My patch has been in Linus's tree for weeks, and until you show me a
real reason why the check shouldn't be there in the ipv6 path, it's
staying.
