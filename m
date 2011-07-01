From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] jme: Cleanup PM operations after using
 new PM API
Date: Thu, 30 Jun 2011 23:55:07 -0700 (PDT)
Message-ID: <20110630.235507.62437463109542898.davem@davemloft.net>
References: <1309261110-11883-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arieslee@jmicron.com, devinchiu@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754967Ab1GAG4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 02:56:13 -0400
In-Reply-To: <1309261110-11883-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Tue, 28 Jun 2011 19:38:30 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> 	1. Using enum name instead of numeric value.
> 	2. device_set_wakeup_enable expect bool argument
> 	   adding !!() to the argument to be passed.
> 	3. Remove non-jme-hardware related operations from
> 	   jme_clear_pm()
> 	4. Reuse jme_clear_pm() in jme_resume() and jme_powersave_phy()
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
