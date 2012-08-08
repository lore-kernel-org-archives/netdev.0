From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pptp: lookup route with the proper net namespace
Date: Wed, 08 Aug 2012 15:57:20 -0700 (PDT)
Message-ID: <20120808.155720.117832615962583285.davem@davemloft.net>
References: <1344334991-3441-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757683Ab2HHW5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 18:57:21 -0400
In-Reply-To: <1344334991-3441-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 7 Aug 2012 18:23:11 +0800

> pptp always use init_net as the net namespace to lookup
> route, this will cause route lookup failed in container.
> 
> because we already set the correct net namespace to struct
> sock in pptp_create,so fix this by using sock_net(sk) to
> replace &init_net.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied, thanks.
