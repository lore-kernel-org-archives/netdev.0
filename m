From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: clear IPCB in ip_tunnel_xmit() in case
 dst_link_failure() is called
Date: Wed, 22 Jan 2014 21:24:45 -0800 (PST)
Message-ID: <20140122.212445.2236898585371895394.davem@davemloft.net>
References: <52DE1F60.2060109@cn.fujitsu.com>
	<CALnjE+qFPoK_0EnZ_TWe1sx4s166iSjAH_+1r2uENeS4aRBckQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, daniel.petre@rcs-rds.ro,
	edumazet@google.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755582AbaAWFYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 00:24:48 -0500
In-Reply-To: <CALnjE+qFPoK_0EnZ_TWe1sx4s166iSjAH_+1r2uENeS4aRBckQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Tue, 21 Jan 2014 10:33:36 -0800

> Can you clear IPCB in error path for dst_link_failure(). So that we do
> not clear it twice in fast path.

Indeed, please add this memset() before the dst_link_failure() call.

Thanks.
