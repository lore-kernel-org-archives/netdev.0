From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h:
 remove unused macro pr_fmt()
Date: Tue, 15 Nov 2011 18:38:08 -0500 (EST)
Message-ID: <20111115.183808.2066749950387258221.davem@davemloft.net>
References: <201111152255.pAFMtTo5005370@wpaz5.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	tomoya-linux@dsn.okisemi.com, toshiharu-linux@dsn.okisemi.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757499Ab1KOXiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 18:38:18 -0500
In-Reply-To: <201111152255.pAFMtTo5005370@wpaz5.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 15 Nov 2011 14:55:29 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h: remove unused macro pr_fmt()

It's not unused, it just isn't properly coming before the linux/printk.h
include.
