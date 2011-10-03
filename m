From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: properly handle md5sig_pool references
Date: Sun, 02 Oct 2011 20:33:20 -0400 (EDT)
Message-ID: <20111002.203320.432361429361087401.davem@davemloft.net>
References: <4E853312.1050107@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab1JCAdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 20:33:24 -0400
In-Reply-To: <4E853312.1050107@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Fri, 30 Sep 2011 11:10:10 +0800

> tcp_v4_clear_md5_list() assumes that multiple tcp md5sig peers
> only hold one reference to md5sig_pool. but tcp_v4_md5_do_add()
> increases use count of md5sig_pool for each peer. This patch
> makes tcp_v4_md5_do_add() only increases use count for the first
> tcp md5sig peer.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied, thanks.
