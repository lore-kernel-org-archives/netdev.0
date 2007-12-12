From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] HDLC driver: use unregister_netdev instead of
 unregister_netdevice
Date: Wed, 12 Dec 2007 10:46:14 -0800 (PST)
Message-ID: <20071212.104614.208083873.davem@davemloft.net>
References: <475F490C.2020305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, khc@pm.waw.pl, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758939AbXLLSqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:46:15 -0500
In-Reply-To: <475F490C.2020305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 12 Dec 2007 10:35:56 +0800

> [PATCH] HDLC driver: use unregister_netdev instead of unregister_netdevice
> 
> Since the caller and the upper caller doesn't hod the rtnl semaphore.
> We should use unregister_netdev instead of unregister_netdevice.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks for finding and fixing this bug.
