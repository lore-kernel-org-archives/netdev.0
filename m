From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: prevent network storms caused by linux IPv6
 routers
Date: Wed, 12 Jan 2011 18:52:11 -0800 (PST)
Message-ID: <20110112.185211.181474894.davem@davemloft.net>
References: <20110112183408.GA8417@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932565Ab1AMCvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 21:51:39 -0500
In-Reply-To: <20110112183408.GA8417@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 12 Jan 2011 21:34:08 +0300

> Linux IPv6 forwards unicast packets, which are link layer multicasts...
> The hole was present since day one. I was 100% this check is there, but it is not.
> 
> The problem shows itself, f.e. when Microsoft Network Load Balancer runs on a network.
> This software resolves IPv6 unicast addresses to multicast MAC addresses.
> 
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied, thanks Alexey.
