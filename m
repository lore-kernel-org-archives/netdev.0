From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: don't allow register_netdev with blank name
Date: Mon, 20 Nov 2006 18:46:18 -0500 (EST)
Message-ID: <20061120.184618.48512591.davem@davemloft.net>
References: <20061117134158.3d3f1508@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:12929 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1030515AbWKTXqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 18:46:18 -0500
To: shemminger@osdl.org
In-Reply-To: <20061117134158.3d3f1508@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 17 Nov 2006 13:41:58 -0800

> This bit of old backwards compatibility cruft can be removed in 2.6.20.
> If there is still an device that calls register_netdev()
> with a zero or blank name, it will get -EINVAL from register_netdevice().
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
