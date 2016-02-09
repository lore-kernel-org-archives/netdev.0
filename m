From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] enic: increment devcmd2 result ring in case of
 timeout
Date: Tue, 09 Feb 2016 04:49:02 -0500 (EST)
Message-ID: <20160209.044902.1000602280288311510.davem@davemloft.net>
References: <1454490644-17955-1-git-send-email-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com,
	sanpilla@cisco.com, _govind@gmx.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304AbcBIJtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:49:08 -0500
In-Reply-To: <1454490644-17955-1-git-send-email-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Wed,  3 Feb 2016 14:40:44 +0530

> From: Sandeep Pillai <sanpilla@cisco.com>
> 
> Firmware posts the devcmd result in result ring. In case of timeout, driver
> does not increment the current result pointer and firmware could post the
> result after timeout has occurred. During next devcmd, driver would be
> reading the result of previous devcmd.
> 
> Fix this by incrementing result even in case of timeout.
> 
> Fixes: 373fb0873d43 ("enic: add devcmd2")
> Signed-off-by: Sandeep Pillai <sanpilla@cisco.com>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied and queued up for -stable, thanks.
