From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH: net-next] core: make GRO methods static.
Date: Thu, 29 Nov 2012 13:18:51 -0500 (EST)
Message-ID: <20121129.131851.1493108836243955794.davem@davemloft.net>
References: <1354175725-23382-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab2K2SSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:18:52 -0500
In-Reply-To: <1354175725-23382-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 29 Nov 2012 09:55:25 +0200

> This patch changes three methods to be static and removes their
> EXPORT_SYMBOLs in core/dev.c and their external declaration in
> netdevice.h. The methods, dev_gro_receive(), napi_frags_finish() and
> napi_skb_finish(), which are in the GRO rx path, are not used
> outside core/dev.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks Rami.
