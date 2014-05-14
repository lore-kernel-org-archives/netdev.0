From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] use cond_resched() to replace udelay() when dump eeprom
Date: Wed, 14 May 2014 00:53:30 -0400 (EDT)
Message-ID: <20140514.005330.276486541596607753.davem@davemloft.net>
References: <1399878384-4690-1-git-send-email-acho@suse.com>
	<1399916910.7000.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acho@suse.com, netdev@vger.kernel.org, bpoirier@suse.de
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbaENExb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 00:53:31 -0400
In-Reply-To: <1399916910.7000.16.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Mon, 12 May 2014 10:48:30 -0700

> We still need to time these commands.  Using cond_resched(), the timing
> becomes unpredictable.  Perhaps we can reduce the NVRAM_CMD_TIMEOUT
> counter by a factor of 100 and use msleep(1) instead of udelay(10).

That should work.
