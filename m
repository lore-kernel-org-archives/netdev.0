From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipmr: fix sparse warning when testing origin
 or group
Date: Tue, 22 Jan 2013 14:24:51 -0500 (EST)
Message-ID: <20130122.142451.2203831994177622947.davem@davemloft.net>
References: <50fe2be1.tv57lZmJcPMuyVta%fengguang.wu@intel.com>
	<1358849883-10452-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370Ab3AVTYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:24:53 -0500
In-Reply-To: <1358849883-10452-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 22 Jan 2013 11:18:03 +0100

> mfc_mcastgrp and mfc_origin are __be32, thus we need to convert INADDR_ANY.
> Because INADDR_ANY is 0, this patch just fix sparse warnings.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
