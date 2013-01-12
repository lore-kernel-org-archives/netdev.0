From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ssb: add missing method ssb_gige_get_macaddr
Date: Sat, 12 Jan 2013 15:32:11 -0800 (PST)
Message-ID: <20130112.153211.562541025115995797.davem@davemloft.net>
References: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
	<1358020905-9924-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	m@bues.ch
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab3ALXcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 18:32:12 -0500
In-Reply-To: <1358020905-9924-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 12 Jan 2013 21:01:43 +0100

> When CONFIG_SSB_DRIVER_GIGE is not set the header does not provide the
> needed method.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

This isn't right.

You can't implement this function in a way that the caller cannot
determine that it didn't actually do anything.

You either have to protect calls with ifdefs or make this routine
return an error indication, in response to which the caller can
set a random ethernet address or take some other corrective action.
