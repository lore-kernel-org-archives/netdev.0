From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: ensure to advertise the right fdb remote
Date: Wed, 23 Apr 2014 15:01:42 -0400 (EDT)
Message-ID: <20140423.150142.917822226454423001.davem@davemloft.net>
References: <1398171690-4451-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbaDWTBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 15:01:44 -0400
In-Reply-To: <1398171690-4451-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 22 Apr 2014 15:01:30 +0200

> The goal of this patch is to fix rtnelink notification. The main problem was
> about notification for fdb entry with more than one remote. Before the patch,
> when a remote was added to an existing fdb entry, the kernel advertised the
> first remote instead of the added one. Also when a remote was removed from a fdb
> entry with several remotes, the deleted remote was not advertised.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thank you.
