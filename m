From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smsc911x: Fix deferred probe for interrupt
Date: Sat, 29 Aug 2015 13:09:34 -0700 (PDT)
Message-ID: <20150829.130934.456243212282368124.davem@davemloft.net>
References: <1440787815-24655-1-git-send-email-tony@atomide.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	steve.glendinning@shawell.net
To: tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbbH2UJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 16:09:35 -0400
In-Reply-To: <1440787815-24655-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Lindgren <tony@atomide.com>
Date: Fri, 28 Aug 2015 11:50:15 -0700

> The interrupt handler may not be available when smsc911x probes if the
> interrupt handler is a GPIO controller for example. Let's fix that
> by adding handling for -EPROBE_DEFER.
> 
> Cc: Steve Glendinning <steve.glendinning@shawell.net>
> Signed-off-by: Tony Lindgren <tony@atomide.com>

Applied, thanks.
