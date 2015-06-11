From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: change BUG_ON to WARN for attr set
 failure case
Date: Thu, 11 Jun 2015 16:27:24 -0700 (PDT)
Message-ID: <20150611.162724.1330335369043090316.davem@davemloft.net>
References: <1434046842-24601-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, dsahern@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbbFKX1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 19:27:25 -0400
In-Reply-To: <1434046842-24601-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 11 Jun 2015 11:20:42 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> This particular BUG_ON condition was checking for attr set err in the
> COMMIT phase, which isn't expected (it's a driver bug if PREPARE phase is
> OK but COMMIT fails).  But BUG_ON() is too strong for this case, so change
> to WARN().  BUG_ON() would be warranted if the system was corrupted beyond
> repair, but this is not the case here.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks Scott.
