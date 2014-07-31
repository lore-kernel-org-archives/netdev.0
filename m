From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Make is_kdump_kernel() accessible from
 modules
Date: Thu, 31 Jul 2014 12:22:44 -0700 (PDT)
Message-ID: <20140731.122244.665794236590108427.davem@davemloft.net>
References: <20140730123513.GB14804@redhat.com>
	<53D9E789.4070607@mellanox.com>
	<20140731130756.GE11063@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, andi@firstfloor.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com
To: vgoyal@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaGaTWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 15:22:45 -0400
In-Reply-To: <20140731130756.GE11063@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivek Goyal <vgoyal@redhat.com>
Date: Thu, 31 Jul 2014 09:07:56 -0400

> If there are performance implications of low memory profile, then user
> needs to live with it. Otherwise they should not use low_memory_env
> boot option to begin with.

I personally think we should avoid changing scripts, by having a kdump
kernel force this low_mem profile to be true.
