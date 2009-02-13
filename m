From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] qlge: bugfix: Use netif_receive_skb() and
 vlan_hwaccel_receive_skb().
Date: Thu, 12 Feb 2009 16:38:41 -0800 (PST)
Message-ID: <20090212.163841.37094769.davem@davemloft.net>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752299AbZBMAir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:38:47 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 11 Feb 2009 05:58:31 -0800

> Replace calls to vlan_hwaccel_rx() and netif_rx().
> Thanks to Dave Miller for pointing out the the driver was making
> the wrong upcall for passing packets into the stack.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
